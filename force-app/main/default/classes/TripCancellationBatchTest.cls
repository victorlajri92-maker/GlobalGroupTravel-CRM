@isTest
public class TripCancellationBatchTest {
    
    @testSetup
    static void setupTestData() {
        
        // On crée un compte client de test
        Account testAccount = new Account(
            Name = 'Test Account Cancellation'
        );
        insert testAccount;
        
        // On crée un voyage qui doit être annulé :
        // - commence dans 7 jours
        // - moins de 10 participants
        Trip__c tripToCancel = new Trip__c(
            Name = 'Voyage à Annuler',
            Status__c = 'A venir',
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(14),
            Number_of_Participants__c = 5,
            Account__c = testAccount.Id
        );
        insert tripToCancel;
        
        // On crée un voyage qui NE doit PAS être annulé :
        // - commence dans 7 jours
        // - plus de 10 participants
        Trip__c tripToKeep = new Trip__c(
            Name = 'Voyage à Garder',
            Status__c = 'A venir',
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(14),
            Number_of_Participants__c = 20,
            Account__c = testAccount.Id
        );
        insert tripToKeep;
    }
    
    // Test 1 : Vérifier que le voyage avec moins de 10 participants est annulé
    @isTest
    static void testTripCancellation() {
        
        Test.startTest();
        
        // On lance le batch manuellement
        TripCancellationBatch batch = new TripCancellationBatch();
        Database.executeBatch((Database.Batchable<sObject>) batch, 200);
        
        Test.stopTest();
        
        // On vérifie que le voyage avec 5 participants est bien annulé
        Trip__c cancelledTrip = [
            SELECT Id, Status__c 
            FROM Trip__c 
            WHERE Name = 'Voyage à Annuler' 
            LIMIT 1
        ];
        System.assertEquals('Annulé', cancelledTrip.Status__c, 'Le voyage devrait être annulé');
        
        // On vérifie que le voyage avec 20 participants n'est PAS annulé
        Trip__c keptTrip = [
            SELECT Id, Status__c 
            FROM Trip__c 
            WHERE Name = 'Voyage à Garder' 
            LIMIT 1
        ];
        System.assertEquals('A venir', keptTrip.Status__c, 'Le voyage ne devrait pas être annulé');
    }
}