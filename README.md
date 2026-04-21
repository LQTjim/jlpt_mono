# JLPT Mono

## Screenshots

<table>
  <tr>
    <td width="50%"><img src="readme/60b41dd7cf95f7fb21f39f69f3ae9e429dce8d0e09f978cc80e8ed221984ff5a.png" alt="" /></td>
    <td width="50%"><img src="readme/66862889afe86c4ff683ed5a419aabb6bfba7672f1f3bc08e6015291afbda1f2.png" alt="" /></td>
  </tr>
  <tr>
    <td><img src="readme/eefa8bc13df7ec72191992ef37ce7c140be9dc9b3ac1770a0a5e9b01e5b04655.png" alt="" /></td>
    <td><img src="readme/fba2cf4431eda5d395457672d8018097f782dc13f1f5d0896df7f80c9c13a6d1.png" alt="" /></td>
  </tr>
  <tr>
    <td><img src="readme/202a25c61d51f9af6abcead15e2bfd492c86debfb425cbc296e0ddb44f365271.png" alt="" /></td>
    <td><img src="readme/156b371706147896ea3c972039a6c864a4a7a85908e3fc0c6f81493821fa2fd9.png" alt="" /></td>
  </tr>
  <tr>
    <td><img src="readme/61261c7fc425f84cc79cdd1919b8a590fb1c2a5eafb40fa6f4b980589d497a9f.png" alt="" /></td>
    <td><img src="readme/457a95a35d36f67616c7ed852254ac4a12a1d9a1afa7f6243d8543eaf1a45735.png" alt="" /></td>
  </tr>
</table>

## Prerequisites

- Java 21
- Flutter SDK
- Docker (for PostgreSQL)

## Configuration

The backend requires a local secrets file that is **not committed to version control**.

Copy the example and fill in your values:

```bash
cp backend/src/main/resources/application-local.properties.example \
   backend/src/main/resources/application-local.properties
```


## Backend

```bash
# Start PostgreSQL
cd backend && docker compose -f compose-dev.yaml up -d && cd ..

# Run (from root)
cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=local

# Compile only (from root)
cd backend && ./mvnw compile
```

## Flutter App

```bash
# Install dependencies
cd app && flutter pub get

# Run on iOS simulator
cd app && flutter run -d 4D3E9B39-F419-413C-A6E9-9C018F9B7249 --dart-define-from-file=.env

# Run Widgetbook (component stories) on macOS desktop
cd app && flutter run -d macos -t lib/widgetbook/widgetbook.dart

# Or run Widgetbook on Chrome
cd app && flutter run -d chrome -t lib/widgetbook/widgetbook.dart
```
