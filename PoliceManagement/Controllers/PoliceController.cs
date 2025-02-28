using System.Text.RegularExpressions;
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
                string query = "SELECT V.id_verbale, V.dataViolazione, A.nome, A.cognome, A.cof_fisc, A.città, COUNT(V.id_violazione) as NumeroViolazioni, SUM (V.importo) as TotMulta FROM Anagrafica as A JOIN Verbali as V ON A.id_anagrafica = V.id_anagrafica GROUP BY V.id_verbale, V.dataViolazione, A.nome, A.cognome, A.cof_fisc, A.città;";
                await using (SqlCommand command = new SqlCommand(query, connection))
                {
                    await using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            RecordList.VerbaliList.Add(
                                new ReportBaseModel()
                                {
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
    }
}
