using System.Collections.Generic;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Xml;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using PoliceManagement.Models;

namespace PoliceManagement.Controllers
{
    public class PoliceController : Controller
    {
        private readonly string _connectionString;

        public PoliceController()
        {
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", false, true)
                .Build();

            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public async Task<IActionResult> Index()
        {
            var RecordList = new ReportListModel()
            {
                VerbaliList = new List<ReportBaseModel>()
            };

            await using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                string query = "SELECT V.id_verbale, V.dataViolazione,A.id_anagrafica, A.nome, A.cognome, A.cof_fisc, A.città, COUNT(V.id_violazione) as NumeroViolazioni, SUM (V.importo) as TotMulta FROM Anagrafica as A JOIN Verbali as V ON A.id_anagrafica = V.id_anagrafica GROUP BY V.id_verbale, V.dataViolazione,A.id_anagrafica, A.nome, A.cognome, A.cof_fisc, A.città;";
                await using (SqlCommand command = new SqlCommand(query, connection))
                {
                    await using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            RecordList.VerbaliList.Add(
                                new ReportBaseModel()
                                {
                                    ID_Anagrafica= reader.GetGuid(2),
                                    IDVerbale = reader.GetInt32(0),
                                    DataVerbale = reader.GetDateTime(1),
                                    nome = reader["nome"].ToString(),
                                    cognome = reader["cognome"].ToString(),
                                    CF = reader["cof_fisc"].ToString(),
                                    city = reader["città"].ToString(),
                                    NumeroViolazioni = int.Parse(reader["NumeroViolazioni"].ToString()),
                                    Totale = decimal.Parse(reader["TotMulta"].ToString()),
                                }
                            );
                        }
                    }

                }

            }
            return View(RecordList);
        }

        private async Task<List<Violazioni>> GetViolazionisAsync()
        {
            List<Violazioni> ViolazioniList = new List<Violazioni>();

            await using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                string query = "SELECT * FROM TipoViolazione";
                await using (SqlCommand command = new SqlCommand(query, connection))
                {
                    await using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        //leggiamo tutte le righe dalla tabella Categorie finche non sono esaurite

                        while (await reader.ReadAsync())
                        {
                            ViolazioniList.Add(
                                new Violazioni()
                                {
                                    Id = reader.GetGuid(0),
                                    Descrizione = reader.GetString(1)
                                }
                            );
                        }
                    }

                }

            }
            return ViolazioniList;
        }

        public async Task<IActionResult> Add()
        {
            ViewBag.Select = await GetViolazionisAsync();
            return View();
        }


        [HttpPost]
        public async Task<IActionResult> SaveAdd(ReportAddModel model)
        {
            if (!ModelState.IsValid)
            {
                TempData["Error"] = "Qualcosa è andato storto";
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                return BadRequest(errors);
            }
            try
            {
                await using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    Guid idAnagrafica = Guid.NewGuid();
                    var queryA = "INSERT INTO Anagrafica(id_anagrafica, nome, cognome, indirizzo, città, CAP, cof_fisc) VALUES (@IdAnagrafica, @nome, @cognome, @indirizzo, @citta, @CAP, @cod_fisc)";

                    await using (SqlCommand command = new SqlCommand(queryA, connection))
                    {
                        command.Parameters.AddWithValue("@IdAnagrafica", idAnagrafica);
                        command.Parameters.AddWithValue("@nome", model.Nome);
                        command.Parameters.AddWithValue("@cognome", model.Cognome);
                        command.Parameters.AddWithValue("@indirizzo", model.Indirizzo);
                        command.Parameters.AddWithValue("@citta", model.Citta);
                        command.Parameters.AddWithValue("@CAP", model.CAP);
                        command.Parameters.AddWithValue("@cod_fisc", model.CodFisc);

                        int righeInteressate = await command.ExecuteNonQueryAsync();
                    }
                    var queryV = "INSERT INTO Verbali (id_verbale, id_anagrafica, id_violazione, dataViolazione, indirizzoViolazione, nominativoAgente, dataTrascrizioneVerbale, importo, decurtamentoPunti) VALUES (@id_verbale, @id_anagrafica, @id_violazione, @dataViolazione, @indirizzoViolazione, @nominativoAgente, @dataTrascrizioneVerbale, @importo, @decurtamentoPunti)";

                    await using (SqlCommand command = new SqlCommand(queryV, connection))
                    {
                        command.Parameters.AddWithValue("@id_verbale", model.IdVerbale);
                        command.Parameters.AddWithValue("@id_anagrafica", idAnagrafica);
                        command.Parameters.AddWithValue("@id_violazione", model.IdViolazione);
                        command.Parameters.AddWithValue("@dataViolazione", model.DataViolazione);
                        command.Parameters.AddWithValue("@indirizzoViolazione", model.IndirizzoViolazione);
                        command.Parameters.AddWithValue("@nominativoAgente", model.NominativoAgente);
                        command.Parameters.AddWithValue("@dataTrascrizioneVerbale", model.DataTrascrizioneVerbale);
                        command.Parameters.AddWithValue("@importo", model.Importo);
                        command.Parameters.AddWithValue("@decurtamentoPunti", model.DecurtamentoPunti);

                        int righeInteressate = await command.ExecuteNonQueryAsync();
                    }

                }
                TempData["Success"] = "Dati inseriti correttamente!";
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"Si è verificato un errore durante l'inserimento dei dati. Riprova più tardi. Errore: {ex.Message}";
                return RedirectToAction("Add");
            }
        }

        [HttpGet]
        public async Task<IActionResult> Delete(Guid id, int n)
        {
            try
            {
                await using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    var query = "DELETE V FROM Verbali AS V JOIN Anagrafica AS A ON A.id_anagrafica = V.id_anagrafica WHERE A.id_anagrafica = @id AND V.id_verbale= @n;";

                    await using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        command.Parameters.AddWithValue("@Id", id);
                        command.Parameters.AddWithValue("@n", n);

                        int righeInteressate = await command.ExecuteNonQueryAsync();
                    }
                }
                return RedirectToAction("Index");
            }catch (Exception ex)
            {
                TempData["Error"] = $"Si è verificato un errore durante l'inserimento dei dati. Riprova più tardi. Errore: {ex.Message}";
                return RedirectToAction("Index");
            }
        }
    }
}
