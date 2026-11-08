using System.Text.RegularExpressions;

namespace AppointmentBook.Data.Helper
{
    public class Validator
    {
        public static bool IsValidEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            string emailPattern =
                @"^[^@\s]+@[^@\s]+\.[^@\s]+$";

            return Regex.IsMatch(
                email,
                emailPattern,
                RegexOptions.IgnoreCase
            );
        }

        public static class PasswordValidator
        {
            public static bool HasMinLength(string password)
            {
                return password.Length >= 8;
            }

            public static bool HasUppercase(string password)
            {
                return Regex.IsMatch(password, @"[A-Z]");
            }

            public static bool HasLowercase(string password)
            {
                return Regex.IsMatch(password, @"[a-z]");
            }

            public static bool HasNumber(string password)
            {
                return Regex.IsMatch(password, @"[0-9]");
            }

            public static bool HasSpecialCharacter(string password)
            {
                return Regex.IsMatch(
                    password,
                    @"[!@#$%^&*(),.?"" :{}|<>_\-\\/\[\]]"
                        .Replace(" ", "")
                );
            }

            public static bool IsValid(string password)
            {
                return HasMinLength(password)
                    && HasUppercase(password)
                    && HasLowercase(password)
                    && HasNumber(password)
                    && HasSpecialCharacter(password);
            }
        }

    }
}
