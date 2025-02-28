CREATE DATABASE PoliziaMunicipaleDB

Use PoliziaMunicipaleDB

CREATE TABLE Anagrafica(
id_anagrafica UNIQUEIDENTIFIER PRIMARY KEY,
nome NVARCHAR(100) NOT NULL,
cognome NVARCHAR(100) NOT NULL,
indirizzo NVARCHAR(255) NOT NULL,
città NVARCHAR(255) NOT NULL,
CAP NVARCHAR(255) NOT NULL,
cof_fisc NVARCHAR(17) NOT NULL UNIQUE,
);


CREATE TABLE TipoViolazione	(
id_violazione UNIQUEIDENTIFIER PRIMARY KEY,
descrizione NVARCHAR(255) NOT NULL,
);


/*Una persona può compiere più violazioni e una violazione può essere compiuta da più persone quindi tra loro c'è una relazione MOlti a MOLTI 
e la tabella di congiunzione è VERBALI. Tuttavia allo stesso verbali possono corrispondere più violazioni, quindi voglio chreare una primary Key composta così da poter usare
lo stesso id verbale più volte per una peronsa che ha più violazioni!
*/
CREATE TABLE Verbali(
id_verbale INT NOT NULL,
id_anagrafica UNIQUEIDENTIFIER NOT NULL,
id_violazione UNIQUEIDENTIFIER NOT NULL,
dataViolazione DATETIME NOT NULL,
indirizzoViolazione NVARCHAR(255) NOT NULL,
nominativoAgente NVARCHAR(255) NOT NULL,
dataTrascrizioneVerbale DATETIME NOT NULL,
importo decimal(18,2) NOT NULL,
decurtamentoPunti INT NOT NULL,
CONSTRAINT PK_Verbali PRIMARY KEY (id_verbale, id_anagrafica, id_violazione), 
CONSTRAINT FK_Verbali_Anagrafica FOREIGN KEY (id_anagrafica) REFERENCES Anagrafica (id_anagrafica),
CONSTRAINT FK_Verbali_TipoViolazione FOREIGN KEY (id_violazione) REFERENCES TipoViolazione (id_violazione)
);


-- Ora inserisco i dati nelle tablle!

INSERT INTO TipoViolazione(id_violazione, descrizione) VALUES
(NEWID(), 'Eccesso di velocità'),
(NEWID(), 'Guida in stato di ebbrezza'),
(NEWID(), 'Guida senza cintura di sicurezza'),
(NEWID(), 'Utilizzo del cellulare alla guida'),
(NEWID(), 'Passaggio con il semaforo rosso');

INSERT INTO Anagrafica(id_anagrafica, nome, cognome, indirizzo, città, CAP, cof_fisc) VALUES
(NEWID(), 'Mario', 'Rossi', 'Via Roma 10', 'Milano', '20121', 'RSSMRA80A01H501Z'),
(NEWID(), 'Luca', 'Bianchi', 'Corso Venezia 5', 'Torino', '10121', 'BNCPLC85B01F205X'),
(NEWID(), 'Giulia', 'Verdi', 'Piazza Duomo 3', 'Firenze', '50122', 'VRDGLI90C41D612K'),
(NEWID(), 'Anna', 'Neri', 'Via Garibaldi 8', 'Bologna', '40123', 'NRAANN75D61G312T'),
(NEWID(), 'Francesco', 'Gialli', 'Viale Libertà 15', 'Napoli', '80121', 'GLLFRN95E01C123U');

UPDATE Anagrafica SET città = 'Palermo' WHERE cof_fisc='BNCPLC85B01F205X' ;



DECLARE @p1 UNIQUEIDENTIFIER, @p2 UNIQUEIDENTIFIER, @p3 UNIQUEIDENTIFIER, @p4 UNIQUEIDENTIFIER,@p5 UNIQUEIDENTIFIER, @v1 UNIQUEIDENTIFIER, @v2 UNIQUEIDENTIFIER, @v3 UNIQUEIDENTIFIER, @v4 UNIQUEIDENTIFIER, @v5 UNIQUEIDENTIFIER;

SELECT @p1 = id_anagrafica FROM Anagrafica Where cof_fisc='RSSMRA80A01H501Z';
SELECT @p2 = id_anagrafica FROM Anagrafica Where cof_fisc='BNCPLC85B01F205X';
SELECT @p3 = id_anagrafica FROM Anagrafica Where cof_fisc='VRDGLI90C41D612K';
SELECT @p4 = id_anagrafica FROM Anagrafica Where cof_fisc='NRAANN75D61G312T';
SELECT @p5 = id_anagrafica FROM Anagrafica Where cof_fisc='GLLFRN95E01C123U';

SELECT @v1 = id_violazione FROM TipoViolazione Where descrizione ='Eccesso di velocità';
SELECT @v2 = id_violazione FROM TipoViolazione Where descrizione ='Guida in stato di ebbrezza';
SELECT @v3 = id_violazione FROM TipoViolazione Where descrizione ='Guida senza cintura di sicurezza';
SELECT @v4 = id_violazione FROM TipoViolazione Where descrizione ='Utilizzo del cellulare alla guida';
SELECT @v5 = id_violazione FROM TipoViolazione Where descrizione ='Passaggio con il semaforo rosso';


INSERT INTO Verbali (id_verbale, id_anagrafica, id_violazione, dataViolazione, indirizzoViolazione, nominativoAgente, dataTrascrizioneVerbale, importo, decurtamentoPunti) VALUES
(1, @p1, @v1, '2024-02-20T14:30:00', 'Via della gioia 22', 'Agente Sato', '2024-02-21T09:00:00', 150.00, 3),
(1, @p1, @v2, '2024-02-20T14:30:00', 'Via della gioia 22', 'Agente Sato', '2024-02-21T09:00:00', 50.00, 3),
(2, @p2, @v2, '2024-02-15T09:15:00', 'Via Garibaldi 9', 'Agente Fallon', '2024-02-16T11:00:00', 550.00, 3),
(3, @p2, @v5, '2024-02-10T12:45:00', 'Piazza Duomo 3', 'Agente Malone', '2024-02-11T14:00:00', 350.00, 3),
(4, @p3, @v1, '2024-02-08T16:30:00', 'Viale Libertà 7', 'Agente Sato', '2024-02-09T08:30:00', 30.00, 3),
(5, @p4, @v3, '2024-02-05T20:10:00', 'Via Torino 25', 'Agente Clouseau', '2024-02-06T09:45:00', 500.00, 3),
(6, @p4, @v4, '2024-02-03T11:50:00', 'Corso Italia 11', 'Agente Callaghan', '2024-02-04T10:00:00', 1500.00, 3),
(6, @p4, @v2, '2024-02-03T11:50:00', 'Corso Italia 11', 'Agente Callaghan', '2024-02-04T10:00:00', 120.00, 3),
(7, @p1, @v1, '2024-01-28T08:30:00', 'Piazza San Marco', 'Agente Callaghan', '2024-01-29T09:15:00', 190.00, 3),
(8, @p2, @v5, '2024-01-25T22:00:00', 'Lungomare 33', 'Agente Fallon', '2024-01-26T11:30:00', 63.00, 3),
(9, @p3, @v1, '2025-02-20T14:30:00', 'Via Verolengo 22', 'Agente Clouseau', '2024-02-21T09:00:00', 150.00, 3),
(10, @p4, @v1, '2025-02-15T14:30:00', 'Via Garibaldi 9', 'Agente Fallon', '2024-02-21T09:00:00', 50.00, 3),
(10, @p4, @v5, '2025-02-15T14:30:00', 'Via Garibaldi 9', 'Agente Fallon', '2024-02-21T09:00:00', 75.00, 5);


--1. Conteggio dei verbali trascritti
SELECT COUNT(*) AS Tot_Verbali
From Verbali

--2. Conteggio dei verbali trascritti raggruppati per anagrafe
SELECT A.nome, A.cognome,A.cof_fisc, COUNT(V.id_verbale) as Tot_Verbali
FROM Anagrafica as A
LEFT JOIN Verbali as V
ON A.id_anagrafica = V.id_anagrafica
GROUP BY A.nome, A.cognome, A.cof_fisc

--3. Conteggio dei verbali trascritti raggruppati per tipo di violazione
SELECT T.descrizione, COUNT(V.id_verbale) as Tot_Verbali
FROM Verbali as V
RIGHT JOIN TipoViolazione as T
ON V.id_violazione = T.id_violazione
GROUP BY descrizione

--4. Totale dei punti decurtati per ogni anagrafe
SELECT A.nome, A.cognome, A.cof_fisc,  SUM(V.decurtamentoPunti) as Tot_PuntiDecurtati
FROM Anagrafica as A
LEFT JOIN Verbali as V
ON A.id_anagrafica = V.id_anagrafica
GROUP BY A.nome, A.cognome, A.cof_fisc

--5. Cognome, Nome, Data violazione, Indirizzo violazione, importo e punti decurtati per tutti gli anagrafici residenti a Palermo
SELECT A.nome, A.cognome,V.dataViolazione, V.indirizzoViolazione, V.importo, V.decurtamentoPunti
FROM Anagrafica as A
INNER JOIN Verbali as V
ON A.id_anagrafica = V.id_anagrafica
WHERE A.città= 'Palermo';

--6. Cognome, Nome, Indirizzo, Data violazione, importo e punti decurtati per le violazioni fatte tra il febbraio 2009 e luglio 2009
SELECT A.nome, A.cognome,A.indirizzo, V.dataViolazione, V.importo, V.decurtamentoPunti
FROM Anagrafica as A
INNER JOIN Verbali as V
ON A.id_anagrafica = V.id_anagrafica
WHERE V.dataTrascrizioneVerbale BETWEEN '2009-02-01T00:00:00' AND '2009-07-31T00:00:00';

--7. Totale degli importi per ogni anagrafico
SELECT A.nome, A.cognome, A.cof_fisc,  SUM(V.importo) as Tot_Importo
FROM Anagrafica as A
LEFT JOIN Verbali as V
ON A.id_anagrafica = V.id_anagrafica
GROUP BY A.nome, A.cognome, A.cof_fisc

--8. Visualizzazione di tutti gli anagrafici residenti a Palermo
SELECT * FROM Anagrafica WHERE città='Palermo'

--9. Query che visualizzi Data violazione, Importo e decurta mento punti relativi ad una certa data
DECLARE @date DATETIME
SELECT @date = dataViolazione FROM Verbali WHERE dataViolazione = '2024-02-20T14:30:00'

SELECT V.dataViolazione, V.importo, V.decurtamentoPunti
FROM Verbali as V
WHERE V.dataViolazione = @date;

--10. Conteggio delle violazioni contestate raggruppate per Nominativo dell’agente di Polizia
SELECT V.nominativoAgente, COUNT(*) AS Numero_Violazioni
FROM Verbali as V
GROUP BY V.nominativoAgente;

--11. Cognome, Nome, Indirizzo, Data violazione, Importo e punti decurtati per tutte le violazioni che superino il decurtamento di 5 punti


SELECT A.cognome, A.nome, A.indirizzo, V.dataTrascrizioneVerbale, V.importo, V.decurtamentoPunti
FROM Anagrafica as A
INNER JOIN Verbali as V
ON A.id_anagrafica = V.id_anagrafica
WHERE V.decurtamentoPunti>=5

--12. Cognome, Nome, Indirizzo, Data violazione, Importo e punti decurtati per tutte le violazioni che superino l’importo di 400 euro.
SELECT A.cognome, A.nome, A.indirizzo, V.dataViolazione, V.importo, V.decurtamentoPunti
FROM Anagrafica as A
INNER JOIN Verbali as V
ON A.id_anagrafica = V.id_anagrafica
WHERE V.importo>=400

--EXTRA

--13 - Numero di verbali e importo totale delle multe emesse per ogni agente di polizia
SELECT V.nominativoAgente, COUNT(DISTINCT V.id_verbale) as TOT_Verbali, SUM (V.importo) as TOT_fatturato
FROM Verbali as V
GROUP BY V.nominativoAgente

--14 - Media degli importi delle multe per tipo di violazione

SELECT T.descrizione, AVG(V.importo) as TOT_Importi
FROM Verbali as V
RIGHT JOIN TipoViolazione as T
ON V.id_violazione = T.id_violazione
GROUP BY T.descrizione;


--SELECT per poter fare la GET sull'index del comproller per l'app mvc 

SELECT V.id_verbale, V.dataViolazione, A.nome, A.cognome, A.cof_fisc, A.città, COUNT(V.id_violazione) as NumeroViolazioni, SUM (V.importo) as TotMulta
FROM Anagrafica as A
JOIN Verbali as V
ON A.id_anagrafica = V.id_anagrafica
GROUP BY 
	V.id_verbale, 
    V.dataViolazione, 
    A.nome, 
    A.cognome, 
    A.cof_fisc, 
    A.città;


--SELECT per poter fare la GET per fare un ADD delcontroller per far funzionare il form per l'app mvc

