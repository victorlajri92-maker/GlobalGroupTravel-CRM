trigger OpportunityTrigger on Opportunity (after update) {
    
    // Ce trigger se déclenche APRES la mise à jour d'une Opportunity
    // On passe Trigger.new ET Trigger.oldMap pour pouvoir comparer
    // l'ancien et le nouveau statut de chaque opportunité
    TripHandler.createTripFromOpportunity(Trigger.new, Trigger.oldMap);
}