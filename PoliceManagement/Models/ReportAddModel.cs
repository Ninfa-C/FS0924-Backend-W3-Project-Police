namespace PoliceManagement.Models
{
    public class ReportAddModel
    {
        public Guid IdAnagrafica { get; set; }
        public string Nome { get; set; }
        public string Cognome { get; set; }
        public string Indirizzo { get; set; }
        public string Citta { get; set; }
        public string CAP { get; set; }
        public string CodFisc { get; set; }

        //VERBALE
        public int IdVerbale { get; set; }
        public Guid IdViolazione { get; set; }
        public DateTime DataViolazione { get; set; }
        public string IndirizzoViolazione { get; set; }
        public string NominativoAgente { get; set; }
        public DateTime DataTrascrizioneVerbale { get; set; }
        public decimal Importo { get; set; }
        public int DecurtamentoPunti { get; set; }
    }
}
