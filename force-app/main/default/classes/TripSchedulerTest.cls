@isTest
public class TripSchedulerTest {
    
    @isTest
    static void testScheduler() {
        
        Test.startTest();
        
        // On programme le scheduler comme si c'était Salesforce qui le faisait
        String cronExpression = '0 0 6 * * ?';
        System.schedule('TripSchedulerTest', cronExpression, new TripScheduler());
        
        Test.stopTest();
    }
}