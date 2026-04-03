@isTest
public class TripTriggerTest {
    
    @testSetup
    static void setupTestData() {
        
        // On crée un compte client de test
        Account testAccount = new Account(
            Name = 'Test Account Trip'
        );
        insert testAccount;
    }
    
    // Test 1 : Vérifier qu'un Trip__c avec des dates valides est bien sauvegardé
    @isTest
    static void testValidDates() {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account Trip' LIMIT 1];
        
        Test.startTest();
        
        // On crée un voyage avec des dates valides
        // End Date > Start Date ✅
        Trip__c trip = new Trip__c(
            Name = 'Voyage Test Valide',
            Status__c = 'A venir',
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(10),
            Account__c = acc.Id
        );
        
        // On insère le voyage, ça ne doit pas générer d'erreur
        insert trip;
        
        Test.stopTest();
        
        // On vérifie que le voyage a bien été créé
        List<Trip__c> trips = [SELECT Id FROM Trip__c WHERE Id = :trip.Id];
        System.assertEquals(1, trips.size(), 'Le voyage aurait dû être créé');
    }
    
    // Test 2 : Vérifier qu'un Trip__c avec des dates invalides est bloqué
    @isTest
    static void testInvalidDates() {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account Trip' LIMIT 1];
        
        Test.startTest();
        
        // On crée un voyage avec des dates invalides
        // End Date < Start Date ❌
        Trip__c trip = new Trip__c(
            Name = 'Voyage Test Invalide',
            Status__c = 'A venir',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(5),
            Account__c = acc.Id
        );
        
        // On s'attend à ce que l'insertion échoue
        Boolean hasError = false;
        try {
            insert trip;
        } catch (DmlException e) {
            hasError = true;
            // On vérifie que le message d'erreur est bien le nôtre
            System.assert(
                e.getMessage().contains('La date de fin doit être postérieure à la date de début'),
                'Le message d erreur doit mentionner les dates'
            );
        }
        
        Test.stopTest();
        
        // On vérifie qu'une erreur a bien été levée
        System.assertEquals(true, hasError, 'Une erreur aurait dû être levée');
    }
}