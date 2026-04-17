@isTest
public class TripHandlerTest {
    
    // @testSetup = cette méthode prépare les données de test
    // Elle s'exécute UNE FOIS avant tous les tests de la classe
    @testSetup
    static void setupTestData() {
        
        // On crée un compte client de test
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        // On crée une opportunité de test
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = testAccount.Id,
            Destination__c = 'Paris',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(15),
            Number_of_Participants__c = 20,
            Amount = 5000
        );
        insert testOpp;
    }
    
    // Test 1 : Vérifier qu'un Trip__c est créé quand une Opportunity passe en Closed Won
    @isTest
    static void testCreateTripWhenOpportunityClosedWon() {
        
        // On récupère l'opportunité créée dans setupTestData
        Opportunity opp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity' 
            LIMIT 1
        ];
        
        Test.startTest();
        
        // On passe l'opportunité en Closed Won
        opp.StageName = 'Closed Won';
        update opp;
        
        Test.stopTest();
        
        // On vérifie qu'un Trip__c a bien été créé
        List<Trip__c> trips = [
            SELECT Id, Status__c, Destination__c 
            FROM Trip__c 
            WHERE Opportunity__c = :opp.Id
        ];
        
        // Il doit y avoir exactement 1 voyage créé
        System.assertEquals(1, trips.size(), 'Un Trip__c aurait dû être créé');
        
        // Le statut doit être "A venir"
        System.assertEquals('A venir', trips[0].Status__c, 'Le statut doit être A venir');
        
        // La destination doit être "Paris"
        System.assertEquals('Paris', trips[0].Destination__c, 'La destination doit être Paris');
    }
    
    // Test 2 : Vérifier qu'aucun Trip__c n'est créé si l'opportunité n'est pas Closed Won
    @isTest
    static void testNoTripCreatedWhenNotClosedWon() {
        
        Opportunity opp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity' 
            LIMIT 1
        ];
        
        Test.startTest();
        
        // On passe l'opportunité en Closed Lost (pas Closed Won)
        opp.StageName = 'Closed/Lost';
        update opp;
        
        Test.stopTest();
        
        // On vérifie qu'aucun Trip__c n'a été créé
        List<Trip__c> trips = [
            SELECT Id 
            FROM Trip__c 
            WHERE Opportunity__c = :opp.Id
        ];
        
        System.assertEquals(0, trips.size(), 'Aucun Trip__c ne devrait être créé');
    }
    
    // Test 3 : Vérifier qu'une erreur est levée si les dates sont invalides
    // Ce test couvre le nouveau bloc de validation ajouté dans TripHandler
    @isTest
    static void testInvalidDatesOnClosedWon() {
        
        // On récupère l'opportunité et on met des dates invalides
        // End Date avant Start Date = dates incorrectes
        Opportunity opp = [
            SELECT Id, StageName, Start_Date__c, End_Date__c
            FROM Opportunity 
            WHERE Name = 'Test Opportunity' 
            LIMIT 1
        ];
        
        // On inverse les dates pour les rendre invalides
        opp.Start_Date__c = Date.today().addDays(10);
        opp.End_Date__c = Date.today().addDays(5);
        update opp;
        
        Test.startTest();
        
        // On passe en Closed Won avec des dates invalides
        opp.StageName = 'Closed Won';
        
        Boolean hasError = false;
        try {
            // Cette mise à jour doit échouer car les dates sont invalides
            update opp;
        } catch (DmlException e) {
            // On récupère l'erreur et on confirme qu'elle a bien eu lieu
            hasError = true;
        }
        
        Test.stopTest();
        
        // On vérifie qu'une erreur a bien été levée
        System.assertEquals(true, hasError, 'Une erreur aurait dû être levée pour des dates invalides');
    }
}