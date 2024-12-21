import 'package:flutter/material.dart';
import 'package:wanderscout/Davin/models/touristattraction.dart';
import 'package:wanderscout/Davin/API/tourist_api.dart';

class AdminTouristAttractionScreen extends StatefulWidget {
  const AdminTouristAttractionScreen({super.key});

  @override
  State<AdminTouristAttractionScreen> createState() =>
      _AdminTouristAttractionScreenState();
}

class _AdminTouristAttractionScreenState
    extends State<AdminTouristAttractionScreen> {
  final ScrollController _scrollController = ScrollController();
  final TouristAttractionApi _api = TouristAttractionApi();

  List<TouristAttraction> _displayedAttractions = [];
  final List<TouristAttraction> _allAttractions = [];
  List<TouristAttraction> _filteredAttractions = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  String _searchQuery = '';
  String _selectedType = 'All';
  List<String> _availableTypes = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchTouristAttractions();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _loadMoreAttractions();
      }
    });
  }

  Future<void> _fetchTouristAttractions() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Example call: "tourist_api/api_tourist_attractions"
      final fetchedAttractions = await _api.fetchTouristAttractions(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _allAttractions.addAll(fetchedAttractions);

        // Collect unique top-level types
        final types = _allAttractions
            .map((attraction) => attraction.type.split(',').first.trim())
            .toSet()
            .toList();
        _availableTypes = ['All', ...types];

        _filteredAttractions = List.from(_allAttractions);
        _displayedAttractions.addAll(fetchedAttractions.take(_pageSize));

        if (fetchedAttractions.length < _pageSize) _hasMore = false;
        _currentPage++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching attractions: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterAttractions() {
    setState(() {
      _filteredAttractions = _allAttractions.where((attraction) {
        final matchesSearchQuery = attraction.nama
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final matchesType = _selectedType == 'All' ||
            attraction.type.split(',').first.trim() == _selectedType;
        return matchesSearchQuery && matchesType;
      }).toList();

      _displayedAttractions = _filteredAttractions.take(_pageSize).toList();
      _hasMore = _filteredAttractions.length > _pageSize;
    });
  }

  void _loadMoreAttractions() {
    if (_displayedAttractions.length >= _filteredAttractions.length ||
        _isLoading ||
        !_hasMore) { return; }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final nextItems = _filteredAttractions
          .skip(_displayedAttractions.length)
          .take(_pageSize)
          .toList();

      setState(() {
        _displayedAttractions.addAll(nextItems);
        _isLoading = false;
      });
    });
  }

  String getImageForAttractionType(String? type) {
    final firstCategory =
        type?.split(',').first.trim().replaceAll(' ', '').toLowerCase() ??
            'placeholder';
    return 'lib/static/attractions/$firstCategory.png';
  }

  Future<void> _deleteAttraction(TouristAttraction attraction) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attraction'),
        content: Text('Are you sure you want to delete "${attraction.nama}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _api.deleteTouristAttraction(attraction.id);
        setState(() {
          _allAttractions.removeWhere((item) => item.id == attraction.id);
          _filteredAttractions.removeWhere((item) => item.id == attraction.id);
          _displayedAttractions.removeWhere((item) => item.id == attraction.id);
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('Attraction deleted successfully')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error deleting attraction: $e')),
        );
      }
    }
  }

  Future<void> _navigateToAddPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAttractionScreen()),
    );
    if (result == true) {
      // Refresh list
      setState(() {
        _allAttractions.clear();
        _filteredAttractions.clear();
        _displayedAttractions.clear();
        _currentPage = 1;
        _hasMore = true;
      });
      _fetchTouristAttractions();
    }
  }

  Future<void> _navigateToEditPage(TouristAttraction attraction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAttractionScreen(attraction: attraction),
      ),
    );
    if (result == true) {
      // Refresh list
      setState(() {
        _allAttractions.clear();
        _filteredAttractions.clear();
        _displayedAttractions.clear();
        _currentPage = 1;
        _hasMore = true;
      });
      _fetchTouristAttractions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin - Tourist Attractions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF313EBC), // Warna biru tua untuk AppBar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF313EBC), // Biru tua
              Color(0xFF87CEFA), // Biru terang
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Search & Filter
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Search by name
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: (value) {
                        _searchQuery = value;
                        _filterAttractions();
                      },
                      decoration: InputDecoration(
                        labelText: 'Search by name...',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(0.2), // Transparan putih
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter by type
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      value: _selectedType,
                      items: _availableTypes
                          .map((type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                            _filterAttractions();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // List of attractions
            Expanded(
              child: _allAttractions.isEmpty && !_isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                          _loadMoreAttractions();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount:
                            _displayedAttractions.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < _displayedAttractions.length) {
                            final attraction = _displayedAttractions[index];
                            return Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFFFFF), // Putih
                                    Color(0xFF87CEFA), // Biru terang (gradient)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.only(bottom: 16.0),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: isSmallScreen
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.asset(
                                                getImageForAttractionType(
                                                  attraction.type,
                                                ),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 200,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            buildAttractionDetails(attraction),
                                            const SizedBox(height: 8),
                                            buildAdminButtons(attraction),
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.asset(
                                                getImageForAttractionType(
                                                  attraction.type,
                                                ),
                                                fit: BoxFit.cover,
                                                width: 150,
                                                height: 150,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  buildAttractionDetails(
                                                      attraction),
                                                  const SizedBox(height: 8),
                                                  buildAdminButtons(attraction),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            );
                          } else {
                            // Loading indicator at the bottom
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPage,
        child: const Icon(Icons.add),
      ),
    );
  }


  Widget buildAttractionDetails(TouristAttraction attraction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          attraction.nama,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Teks nama menjadi hitam
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rating: ${attraction.voteAverage} / 5',
          style: const TextStyle(
            color: Colors.black, // Teks rating menjadi hitam
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Type: ${attraction.type}',
          style: const TextStyle(
            color: Colors.black, // Teks type menjadi hitam
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Weekday Price: IDR ${attraction.htmWeekday}',
          style: const TextStyle(
            color: Colors.black, // Teks weekday price menjadi hitam
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Weekend Price: IDR ${attraction.htmWeekend}',
          style: const TextStyle(
            color: Colors.black, // Teks weekend price menjadi hitam
          ),
        ),
      ],
    );
  }

  Widget buildAdminButtons(TouristAttraction attraction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.orange),
          onPressed: () {
            _navigateToEditPage(attraction);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _deleteAttraction(attraction);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

extension on Color {
  withValues(double d) {}
}

class AddAttractionScreen extends StatefulWidget {
  const AddAttractionScreen({super.key});

  @override
  State<AddAttractionScreen> createState() => _AddAttractionScreenState();
}

class _AddAttractionScreenState extends State<AddAttractionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TouristAttractionApi _api = TouristAttractionApi();

  // For numeric/text fields
  final TextEditingController _noController = TextEditingController();
  final TextEditingController _voteCountController = TextEditingController();
  final TextEditingController _htmWeekdayController = TextEditingController();
  final TextEditingController _htmWeekendController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _gmapsUrlController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();

  // Sliders
  double _rating = 0.0;
  double _voteAverage = 0.0;

  // Type dropdown
final List<String> _typeOptions = [
  'Budaya dan Sejarah',
  'Alam',
  'Buatan',
  'Wisata Air',
  'Pantai',
  'Museum',
  'Agrowisata',
  'Desa Wisata'
];

  String _selectedType = 'Alam';

  bool _isSubmitting = false;

  // Validation
  String? _nonEmptyValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  String? _intValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    if (int.tryParse(value) == null) {
      return 'Enter a valid integer';
    }
    return null;
  }

  String? _doubleValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    if (double.tryParse(value) == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final newAttraction = TouristAttraction(
        id: '',
        no: int.parse(_noController.text),
        nama: _namaController.text,
        rating: _rating,
        voteAverage: _voteAverage,
        voteCount: int.parse(_voteCountController.text),
        type: _selectedType,
        htmWeekday: int.parse(_htmWeekdayController.text),
        htmWeekend: int.parse(_htmWeekendController.text),
        description: _descriptionController.text,
        gmapsUrl: _gmapsUrlController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
      );

      // Example call: "tourist_api/api_tourist_attractions/add"
      await _api.addTouristAttraction(newAttraction);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attraction added successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding attraction: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _noController.dispose();
    _voteCountController.dispose();
    _htmWeekdayController.dispose();
    _htmWeekendController.dispose();
    _descriptionController.dispose();
    _gmapsUrlController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Attraction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // no
              TextFormField(
                controller: _noController,
                decoration: const InputDecoration(labelText: 'No'),
                validator: _intValidator,
                keyboardType: TextInputType.number,
              ),

              // Name
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _nonEmptyValidator,
              ),

              // rating slider
              const SizedBox(height: 12),
              const Text('Rating (0-5)'),
              Slider(
                value: _rating,
                min: 0,
                max: 5,
                divisions: 5, // steps of 1.0
                label: _rating.toString(),
                onChanged: (double value) {
                  setState(() => _rating = value);
                },
              ),

              // voteAverage slider
              const SizedBox(height: 12),
              const Text('Vote Average (0-5)'),
              Slider(
                value: _voteAverage,
                min: 0,
                max: 5,
                divisions: 5,
                label: _voteAverage.toString(),
                onChanged: (double value) {
                  setState(() => _voteAverage = value);
                },
              ),

              // voteCount
              TextFormField(
                controller: _voteCountController,
                decoration: const InputDecoration(labelText: 'Vote Count'),
                validator: _intValidator,
                keyboardType: TextInputType.number,
              ),

              // type: dropdown
              const SizedBox(height: 12),
              const Text('Select Type'),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _typeOptions
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),

              // Weekday Price
              TextFormField(
                controller: _htmWeekdayController,
                decoration:
                    const InputDecoration(labelText: 'Weekday Price (IDR)'),
                validator: _intValidator,
                keyboardType: TextInputType.number,
              ),

              // Weekend Price
              TextFormField(
                controller: _htmWeekendController,
                decoration:
                    const InputDecoration(labelText: 'Weekend Price (IDR)'),
                validator: _intValidator,
                keyboardType: TextInputType.number,
              ),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: _nonEmptyValidator,
              ),

              // Google Maps URL
              TextFormField(
                controller: _gmapsUrlController,
                decoration: const InputDecoration(labelText: 'Google Maps URL'),
                validator: _nonEmptyValidator,
              ),

              // Latitude
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                validator: _doubleValidator,
                keyboardType: TextInputType.number,
              ),

              // Longitude
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                validator: _doubleValidator,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Attraction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class EditAttractionScreen extends StatefulWidget {
  final TouristAttraction attraction;

  const EditAttractionScreen({super.key, required this.attraction});

  @override
  State<EditAttractionScreen> createState() => _EditAttractionScreenState();
}

class _EditAttractionScreenState extends State<EditAttractionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TouristAttractionApi _api = TouristAttractionApi();

  // For numeric/text fields
  late TextEditingController _noController;
  late TextEditingController _voteCountController;
  late TextEditingController _htmWeekdayController;
  late TextEditingController _htmWeekendController;
  late TextEditingController _descriptionController;
  late TextEditingController _gmapsUrlController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _namaController;

  // Sliders
  double _rating = 0.0;
  double _voteAverage = 0.0;

  // Type dropdown
final List<String> _typeOptions = [
  'Budaya dan Sejarah',
  'Alam',
  'Buatan',
  'Wisata Air',
  'Pantai',
  'Museum',
  'Agrowisata',
  'Desa Wisata'
];

  late String _selectedType;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers from existing attraction
    _noController = TextEditingController(text: widget.attraction.no.toString());
    _voteCountController =
        TextEditingController(text: widget.attraction.voteCount.toString());
    _htmWeekdayController =
        TextEditingController(text: widget.attraction.htmWeekday.toString());
    _htmWeekendController =
        TextEditingController(text: widget.attraction.htmWeekend.toString());
    _descriptionController =
        TextEditingController(text: widget.attraction.description);
    _gmapsUrlController =
        TextEditingController(text: widget.attraction.gmapsUrl);
    _latitudeController =
        TextEditingController(text: widget.attraction.latitude.toString());
    _longitudeController =
        TextEditingController(text: widget.attraction.longitude.toString());
    _namaController = TextEditingController(text: widget.attraction.nama);

    // Initialize sliders
    _rating = widget.attraction.rating;
    _voteAverage = widget.attraction.voteAverage;

    // If the current attraction type is not in _typeOptions, fallback to 'Others'
    _selectedType = _typeOptions.contains(widget.attraction.type)
        ? widget.attraction.type
        : 'Others';
  }

  @override
  void dispose() {
    _noController.dispose();
    _voteCountController.dispose();
    _htmWeekdayController.dispose();
    _htmWeekendController.dispose();
    _descriptionController.dispose();
    _gmapsUrlController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  String? _nonEmptyValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  String? _intValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    if (int.tryParse(value) == null) {
      return 'Enter a valid integer';
    }
    return null;
  }

  // ignore: unused_element
  String? _doubleValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    if (double.tryParse(value) == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final updatedAttraction = TouristAttraction(
        id: widget.attraction.id,
        no: int.parse(_noController.text),
        nama: _namaController.text,
        rating: _rating,
        voteAverage: _voteAverage,
        voteCount: int.parse(_voteCountController.text),
        type: _selectedType,
        htmWeekday: int.parse(_htmWeekdayController.text),
        htmWeekend: int.parse(_htmWeekendController.text),
        description: _descriptionController.text,
        gmapsUrl: _gmapsUrlController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
      );

      await _api.editTouristAttraction(updatedAttraction);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attraction updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating attraction: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Edit Attraction',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF313EBC), // Dark blue
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF313EBC), // Dark blue
            Color(0xFF87CEFA), // Light blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25), // 10% opacity
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field "No"
                  const Text(
                    'No',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(240, 240, 240, 1), // Light gray
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _intValidator,
                  ),
                  const SizedBox(height: 16),

                  // Field "Name"
                  const Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(240, 240, 240, 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: _nonEmptyValidator,
                  ),
                  const SizedBox(height: 16),

                  // Rating Slider
                  const Text(
                    'Rating (0-5)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    activeColor: Colors.blue,
                    inactiveColor: const Color.fromRGBO(200, 200, 200, 1), // Light gray
                    label: _rating.toString(),
                    onChanged: (double value) {
                      setState(() => _rating = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Vote Average Slider
                  const Text(
                    'Vote Average (0-5)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _voteAverage,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    activeColor: Colors.blue,
                    inactiveColor: const Color.fromRGBO(200, 200, 200, 1),
                    label: _voteAverage.toString(),
                    onChanged: (double value) {
                      setState(() => _voteAverage = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Field "Vote Count"
                  const Text(
                    'Vote Count',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _voteCountController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(240, 240, 240, 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _intValidator,
                  ),
                  const SizedBox(height: 16),

                  // Type Dropdown
                  const Text(
                    'Select Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: _typeOptions
                        .map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedType = value);
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(240, 240, 240, 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weekday Price
                  const Text(
                    'Weekday Price (IDR)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _htmWeekdayController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(240, 240, 240, 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _intValidator,
                  ),
                  const SizedBox(height: 16),

                  // Weekend Price
                  const Text(
                    'Weekend Price (IDR)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _htmWeekendController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(240, 240, 240, 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _intValidator,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(240, 240, 240, 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 3,
                    validator: _nonEmptyValidator,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF313EBC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update Attraction',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


}
