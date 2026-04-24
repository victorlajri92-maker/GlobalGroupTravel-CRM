public class TripHandler {
    
    // Cette méthode est appelée par le trigger OpportunityTrigger
    // Elle reçoit la liste des opportunités qui viennent d'être mises à jour
    // ET l'ancienne version de chaque opportunité pour comparer les changements
    public static void createTripFromOpportunity(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunityMap) {
        
        // On crée une liste vide qui va stocker les voyages à créer
        List<Trip__c> tripsToCreate = new List<Trip__c>();
        
        // On parcourt chaque opportunité mise à jour
        for (Opportunity opp : newOpportunities) {
            
            // On récupère l'ancienne version de cette opportunité
            Opportunity oldOpp = oldOpportunityMap.get(opp.Id);
            
            // On vérifie deux choses :
            // 1. L'opportunité est bien en "Closed Won" MAINTENANT
            // 2. Elle N'ÉTAIT PAS déjà en "Closed Won" AVANT
            // Si elle était déjà en Closed Won → on ne recrée pas de Trip__c !
            if (opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
                
                // On vérifie les dates avant de créer le Trip__c
                if (opp.Start_Date__c != null && opp.End_Date__c != null
                    && opp.End_Date__c <= opp.Start_Date__c) {
                    
                    // REMARQUE 2 : on utilise continue au lieu de return
                    // pour ne pas bloquer les autres opportunités
                    // On ajoute l'erreur uniquement sur cette opportunité
                    opp.addError('La date de fin doit être postérieure à la date de début.');
                    continue; // On passe à l'opportunité suivante
                }
                
                // On crée un nouveau voyage avec les infos de l'opportunité
                Trip__c newTrip = new Trip__c(
                    Name = 'Voyage - ' + opp.Name,
                    Status__c = 'A venir',
                    Destination__c = opp.Destination__c,
                    Start_Date__c = opp.Start_Date__c,
                    End_Date__c = opp.End_Date__c,
                    Number_of_Participants__c = opp.Number_of_Participants__c,
                    Total_Cost__c = opp.Amount,
                    Account__c = opp.AccountId,
                    Opportunity__c = opp.Id
                );
                
                // On ajoute ce voyage à notre liste
                tripsToCreate.add(newTrip);
            }
        }
        
        // Si notre liste n'est pas vide, on insère tous les voyages en une seule fois
        // C'est la bonne pratique Salesforce : jamais de DML dans une boucle !
        if (!tripsToCreate.isEmpty()) {
            insert tripsToCreate;
        }
    }
}