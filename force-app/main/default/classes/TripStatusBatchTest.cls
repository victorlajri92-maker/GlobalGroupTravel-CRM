@isTest
public class TripStatusBatchTest {
    
    @testSetup
    static void setupTestData() {
        
        Account testAccount = new Account(
            Name = 'Test Account Status'
        );
        insert testAccount;
        
        // Voyage "A venir" : commence dans le futur
        Trip__c tripAvenir = new Trip__c(
            Name = 'Voyage A Venir',
            Status__c = 'Terminé',
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(10),
            Account__c = testAccount.Id
        );
        insert tripAvenir;
        
        // Voyage "En cours" : commence aujourd'hui ou avant, finit après
        Trip__c tripEnCours = new Trip__c(
            Name = 'Voyage En Cours',
            Status__c = 'A venir',
            Start_Date__c = Date.today().addDays(-2),
            End_Date__c = Date.today().addDays(3),
            Account__c = testAccount.Id
        );
        insert tripEnCours;
        
        // Voyage "Terminé" : déjà fini
        Trip__c tripTermine = new Trip__c(
            Name = 'Voyage Terminé',
            Status__c = 'A venir',
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(-5),
            Account__c = testAccount.Id
        );
        insert tripTermine;
    }
    
    @isTest
    static void testStatusUpdate() {
        
        Test.startTest();
        
        // On lance le batch
        TripStatusBatch batch = new TripStatusBatch();
        Database.executeBatch((Database.Batchable<sObject>) batch, 200);
        
        Test.stopTest();
        
        // On vérifie le voyage "A venir"
        Trip__c tripAvenir = [
            SELECT Status__c 
            FROM Trip__c 
            WHERE Name = 'Voyage A Venir' 
            LIMIT 1
        ];
        System.assertEquals('A venir', tripAvenir.Status__c, 'Le statut devrait être A venir');
        
        // On vérifie le voyage "En cours"
        Trip__c tripEnCours = [
            SELECT Status__c 
            FROM Trip__c 
            WHERE Name = 'Voyage En Cours' 
            LIMIT 1
        ];
        System.assertEquals('En cours', tripEnCours.Status__c, 'Le statut devrait être En cours');
        
        // On vérifie le voyage "Terminé"
        Trip__c tripTermine = [
            SELECT Status__c 
            FROM Trip__c 
            WHERE Name = 'Voyage Terminé' 
            LIMIT 1
        ];
        System.assertEquals('Terminé', tripTermine.Status__c, 'Le statut devrait être Terminé');
    }
}