﻿namespace PoliceManagement.Models
{
    public class Anagrafica
    {
        public Guid IdAnagrafica { get; set; }
        public string Nome { get; set; }
        public string Cognome { get; set; }
        public string Indirizzo { get; set; }
        public string Citta { get; set; }
        public string CAP { get; set; }
        public string CodFisc { get; set; }
    }
}
