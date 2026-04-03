trigger OpportunityTrigger on Opportunity (after update) {
    
    // Ce trigger se déclenche APRES la mise à jour d'une Opportunity
    // "after update" = on attend que Salesforce ait sauvegardé les données
    // avant d'agir. C'est important car on a besoin de l'ID de l'opportunité
    
    // On appelle simplement notre classe TripHandler
    // en lui passant la liste des opportunités mises à jour
    // Trigger.new = la liste de TOUTES les opportunités qui viennent d'être modifiées
    TripHandler.createTripFromOpportunity(Trigger.new);
}