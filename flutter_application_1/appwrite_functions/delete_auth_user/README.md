Create an Appwrite Function with ID `delete-auth-user` and deploy the files in this folder.

Required settings:
- Runtime: `Dart`
- Entrypoint: `main.dart`
- API key env var: `APPWRITE_API_KEY`

The API key used by the function must have permission to manage users.

What this function does:
- accepts a JSON body with `userId`
- deletes the Appwrite Auth user with that ID
- returns a JSON success/error response

Your Flutter app now calls this function before deleting the matching row from the users table.
