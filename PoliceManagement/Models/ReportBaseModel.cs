namespace PoliceManagement.Models
{
    public class ReportBaseModel
    {
        public int IDVerbale { get; set; }
        public DateTime DataVerbale { get; set; }
        public string Data => DataVerbale.ToShortDateString();
        public string Ora => DataVerbale.ToString("HH:mm");
        public string nome { get; set; }
        public string cognome { get; set; }
        public string CF { get; set; }
        public string city { get; set; }
        public int NumeroViolazioni { get; set; }
        public decimal Totale { get; set; }
    }
}
