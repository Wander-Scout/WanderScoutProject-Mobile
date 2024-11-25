<h2><b>List of group member names</b></h2>
Alano Davin Mandagi Awuy 2306172363
<br>
Samuella Putri Nadia Pauntu 2306170446
<br>
Kezia Salsalina Agtyra Sebayang 2306172086
<br>
Hafizh Surya Mustafa Zen 2306256343
<br>
Heinrich Edric Damadika Suselo 2306256356

<h2><b>Link to the APK (not required at Stage I. The APK link can be added to README.md after completing Stage II.)</b></h2>


<h2><b>Application description (name and purpose of the application)</b></h2>
WanderScout is the ultimate travel companion for exploring the enchanting city of Yogyakarta. Designed to be more than just a guide, this app brings the latest updates through news, must-visit restaurants, and curated tourist attractions. Whether you're a local adventurer or an international traveler, WanderScout will help you uncover the hidden gems of Yogyakarta.

<br>

We offer a user-friendly platform, which not only simplifies trip planning but also introduces you to hidden gems and cultural wonders you won't find in any other platform. WanderScout ensures your journey to Yogyakarta is unforgettable. 

<h2><b>List of modules implemented and the division of work among group members</b></h2>

**Login, Authentication, and Security:**
<br>
A login and register widget where users can create an account and login to that account from both the web app and the mobile app. This module will have the goal of ensuring that when a user is made or does a certain action the data will then be properly stored on both the web and mobile app.

**Customer review:**
<br>
Users who are tourists can access through a widget the ability to add and see other reviews. Admins can reply to user reviews and users can see the reply. The created reviews must exist on both web app and mobile app.   

**Restaurants:**  
Users can view a list of restraunts with the displayed data and detailed page. The restraunts have price ranges and different themes. Users can add it to their cart on both platform and all admin changes will be reflected on both apps.

**Tourist Attractions:**  
Users can browse tourist spots, including hidden gems, with all information available on both platforms. If an admin added new data it should appear on both platforms. Tourist can add a attraction to their shopping cart which should show change on both platforms. A detailed page is offered per item.

**News:**  
Users can access local news, events, and travel advisories via an integrated RSS feed, updated on both web and mobile apps meaning all displayed should be the same.

**Shopping Cart:**  
Users can manage cart items and complete bookings with receipts, synced across web and mobile apps. They can add either a restruant or a attraction and a rough price will be given to give an idea of what the cost would be.  

<h2><b>Roles or actors of the user application</b><h2>

<h3>User Features</h3>

<p>The mobile version of the platform is designed to provide users with seamless access to services and content through a responsive and intuitive interface. The following features are available to users:</p>

<h4>1. Account Management</h4>  
<p>Users can register for an account, log in, and update their profile details as needed.</p>

<h4>2. Browse Content</h4>  
<p>Users have access to a wide range of features, including:</p>
<ul>
  <li>Restaurants: Explore a curated list of restaurants with descriptions and price ranges.</li>
  <li>Tourist Attractions: Discover iconic landmarks and hidden gems, with detailed pages for each attraction.</li>
  <li>News: Stay informed with the latest news, travel advisories, and local events through an integrated RSS feed.</li>
</ul>

<h4>3. Shopping Cart Management</h4>
<p>Users can add restaurants and attractions to their shopping cart, view a rough estimate of the total cost, and proceed to checkout. Receipts are generated for all completed bookings.</p>

<h4>4. Review Functionality</h4> 
<p>Users can:</p>
<ul>
  <li>Submit reviews for the website.</li>
  <li>View reviews submitted by other users.</li>
  <li>Read admin responses to their reviews.</li>
</ul>

<h3>Admin Features</h3>

<p>Admins in the mobile version of the application retain elevated permissions, ensuring efficient content management and user interaction oversight. Below is a breakdown of the functionalities available to admins:</p>

<h4>1. Manage Content Across Platforms</h4>
<p>Admins can add, edit, or delete platform content, including news articles, restaurant details, and tourist attractions. Any updates made by admins are reflected seamlessly on both the web and mobile applications, ensuring that users have access to accurate and consistent information.</p>

<h4>2. Moderate and Respond to Customer Reviews</h4>
<p>Admins have the ability to view and respond to user reviews directly. This feature allows admins to address user feedback, provide clarifications, and foster positive interactions. By engaging with user reviews, admins enhance the overall user experience and ensure feedback is valued.</p>

<h4>3. System Maintenance</h4>
<p>Admins are responsible for ensuring the smooth operation of the mobile application. This includes performing system updates, troubleshooting issues, and managing security protocols.</p>

<h2><b>Integration with the web service to connect to the web application created in the midterm project</b></h2>

## Overview
This section describes the integration of our Flutter mobile application with the Django web application developed during the midterm project. The integration includes apps like `restaurant` and `tourist_attraction` apps, enabling dynamic data management and display within the mobile application.

## Web Application Details
- **Framework:** Django
- **Purpose:** The Django application serves as the backend for managing data related to restaurants and tourist attractions. It provides RESTful APIs for CRUD operations and dynamic data handling.
- **Link to Midterm Project Documentation:** [Midterm Project Details](https://github.com/Wander-Scout/WanderScoutProject)

## Integration Steps

1. **API Endpoints**:
   - Each app (e.g., `restaurant`, `tourist_attraction`) exposes RESTful API endpoints for CRUD operations (Create, Read, Update, Delete).
   - These endpoints handle tasks like fetching data lists, adding new records, updating details, and deleting entries.

2. **API Communication**:
   - The Flutter mobile app sends HTTP requests to these endpoints using the `http` package.
   - Requests include necessary data (e.g., restaurant name or updated details) in JSON format.
   - The Django backend processes these requests, interacts with the database, and returns JSON responses.

3. **Data Parsing and Display**:
   - The mobile app receives JSON responses (e.g., a list of restaurants or an error message).
   - Flutter parses this JSON data and uses widgets to dynamically update the user interface (e.g., display restaurant cards or show details).

4. **User Interaction**:
   - Admins perform actions (e.g., add a new attraction, edit restaurant details).
   - These actions trigger the appropriate HTTP requests to the backend.

5. **Authentication**:
   - Protected endpoints (e.g., adding or deleting records) require user authentication.
   - The mobile app includes authentication tokens in its requests to access these endpoints.

---

### Example APPS
## Restaurants App
1. **API Endpoints**:
   - **GET `/api/`**: Fetches all restaurants.
   - **POST `/api/add_restaurant/`**: Adds a new restaurant.
   - **DELETE `/api/delete_restaurant/<uuid:restaurant_id>/`**: Deletes a specific restaurant.

2. **Features Enabled**:
   - Display restaurant data.
   - Add, update, and delete restaurant records dynamically (for admins).
   - Role-based access for admin functionalities.

---

## Tourist Attraction App
1. **API Endpoints**:
   - **GET `/api/`**: Fetches all tourist attractions.
   - **POST `/add_attraction/`**: Adds a new tourist attraction.
   - **DELETE `/delete_attraction/<uuid:attraction_id>/`**: Deletes a specific tourist attraction.


2. **Features Enabled**:
   - Display tourist attraction.
   - Add, update, and delete tourist attraction records (for admins).
   - Support for detailed views of specific attractions.

---
