namespace AppointmentBook.Data.Helper
{
    public class Hasher
    {
        public static string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

        public static bool VerifyPassword(
            string password,
            string passwordHash)
        {
            return BCrypt.Net.BCrypt.Verify(
                password,
                passwordHash);
        }
    }
}
