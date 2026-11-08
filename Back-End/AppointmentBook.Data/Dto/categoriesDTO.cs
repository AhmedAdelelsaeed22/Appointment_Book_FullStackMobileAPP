namespace AppointmentBook.Data.Dto
{
    public class categoriesDTO
    {
        public long id { get; set; }

        public string name { get; set; } = null!;


        public categoriesDTO(
            long id,
            string name)
        {
            this.id = id;
            this.name = name;
        }
    }
}