
# Device Reading API

A set of simple Restful APIs, implemented in Ruby on Rails that processes device readings and stores them in memory via `Rails.cache`, can be easily swapped for Redis or other distributed cache.

It supports three endpoints:

1. **POST** `/readings` – Store readings for a device  
2. **GET** `/devices/:id/latest_timestamp` – Fetch the latest reading’s timestamp for a device  
3. **GET** `/devices/:id/cumulative_count` – Fetch the cumulative count of all readings for a device  

---

## 1. Setup

### Prerequisites

- **Ruby** version 3.0+
- **Rails** version 7+
- **Bundler** 

### Steps

1. **Install Dependencies**  
   ```bash
   bundle install
   ```

2. **Start the Server**  
   ```bash
   rails server
   ```
   Default running on [http://localhost:3000](http://localhost:3000).

3. **Run Tests**
   ```bash
   bundle exec rspec
   ```

---

## 2. APIs

### A. Store Readings

**`POST /readings`**  
- **Description**: Receives a device’s readings and stores them in memory.  
- **Curl**:
  ```json
  
   curl -X POST http://localhost:3000/readings \
   -H "Content-Type: application/json" \
   -d '{
    "id": "36d5658a-6908-479e-887e-a949ec199272",
    "readings": [
      {
        "timestamp": "2021-09-29T16:08:15+01:00",
        "count": 2
      },
      {
        "timestamp": "2021-09-29T16:09:15+01:00",
        "count": 15
      }
    ]
  }'
  ```
  - `id` (String): UUID for the device
  - `readings` (Array): A list of reading objects
    - `timestamp` (String): Must be a valid ISO-8601 date-time
    - `count` (Integer): The count

- **Success Response**:  
  - **Status**: 200 OK  
  - **Body**:
    ```json
    { "message": "Readings processed successfully" }
    ```
- **Error Response**:  
  - **Status**: 422 Unprocessable Entity (if validation fails)  
  - **Body**:
    ```json
    { "errors": ["Id can't be blank", "Readings must be an array and cannot be empty"] }
    ```

### B. Fetch the Latest Timestamp

**`GET /devices/:id/latest_timestamp`**  
- **Description**: Returns the timestamp of the most recent reading for the device.  
- **Path Parameter**:
  - `id` (String): The device’s UUID
- **Success Response**:  
  - **Status**: 200 OK  
  - **Curl**:
    ```json
    curl http://localhost:3000/devices/36d5658a-6908-479e-887e-a949ec199272/latest_timestamp
    ```
    If no data is found for the device, the `"latest_timestamp"` field will be `null`.

### C. Fetch the Cumulative Count

**`GET /devices/:id/cumulative_count`**  
- **Description**: Returns the sum of counts for all non-duplicate readings stored for the device.  
- **Path Parameter**:
  - `id` (String): The device’s UUID
- **Success Response**:  
  - **Status**: 200 OK  
  - **Curl**:
    ```json
    curl http://localhost:3000/devices/36d5658a-6908-479e-887e-a949ec199272/cumulative_count
    ```
    If no data is found for the device, the `"cumulative_count"` will be `0`.

---

## 3. Project Structure

### Overview

```
device-reading-api/
├── app
│   ├── controllers
│   │   ├── readings_controller.rb       # /readings
│   │   └── devices_controller.rb        # /devices/:id
│   ├── models
│   │   ├── device_reading_request.rb    # Validates the main request (id + readings)
│   │   └── reading_input.rb             # Validates readings array (timestamp, count)
│   └── services
│       └── device_reading_service.rb    # Encapsulates logic for storing/fetching from Rails.cache
├── config
│   ├── routes.rb                        # Defining the three routes
│   └── ...
├── spec
│   ├── models                           # Model specs
│   ├── requests                         # API endpoint specs
│   └── services                         # Service specs
├── Gemfile
├── Gemfile.lock
├── README.md                            # <--- you are here!
└── ...
```
---

## 4. Improvements & Future Optimizations

- I would have liked to include API versioning, but I chose to save time on configuration and focus on the core functionality. In a real-world scenario, I would definitely add it.
- Better error handling. Right now, a single piece of bad data within the readings array causes the entire request to fail. The API could be more resilient by ignoring the problematic entry or handling it differently, instead of aborting entirely.
-   For high-traffic scenarios, I would consider using a distributed cache. I've allowed for easy swapping of the cache strategy via simple configuration. I did not use Redis or Memcached due to the external services constraint.
-   If devices can send large payloads, it might be best to compress, or batch incoming readings. At some point, the request may still reach a size limit, so we'd need to consider other options.
-   We could look into streaming or asynchronous processing for efficiency, which would need an architecture rewrite.
-   Logging should be definitely be explanded. Currently, we have none due to time constraints.
-   Setup APM middleware.
-   For a production service, we would want add authentication.
---

**Thank you! :)**
```
