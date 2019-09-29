@isTest(SeeAllData=true)
private class pdAccount2Freee_test {
    /*
    @TestSetup
    static void setup(){
        Account acc = new Account();

        acc.Name = 'テスト';
        acc.Phone = '019-618-0161';
        acc.BillingPostalCode = '020-0611';
        acc.BillingState = '岩手県';
        acc.BillingCity = '滝沢市';
        acc.BillingStreet = '巣子152-409\r\n滝沢市第2イノベーションセンター';

        insert acc;
    }
    */

    @isTest
    static void test_account2Freee() {

        Test.setMock(HttpCalloutMock.class, new pdAccount2FreeeCalloutMock());

        Account acc = [select Id from Account limit 1];

        pdAccount2Freee.account2Freee(acc.Id);
    }
}
