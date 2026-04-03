trigger TripTrigger on Trip__c (before insert, before update) {
    
    // Ce trigger se déclenche AVANT l'insertion ou la mise à jour d'un Trip__c
    // "before" = on intervient avant que Salesforce sauvegarde
    // C'est important car on veut bloquer la sauvegarde si les dates sont incorrectes
    
    // On parcourt chaque voyage en cours d'insertion ou de mise à jour
    for (Trip__c trip : Trigger.new) {
        
        // On vérifie que les deux dates sont bien renseignées
        if (trip.Start_Date__c != null && trip.End_Date__c != null) {
            
            // On vérifie que la date de fin est bien APRES la date de début
            if (trip.End_Date__c <= trip.Start_Date__c) {
                
                // Si ce n'est pas le cas, on bloque la sauvegarde
                // et on affiche un message d'erreur sur le champ End_Date__c
                trip.End_Date__c.addError(
                    'La date de fin doit être postérieure à la date de début.'
                );
            }
        }
    }
}