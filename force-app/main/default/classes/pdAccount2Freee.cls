public with sharing class pdAccount2Freee {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    /**
    * 取引先の情報尾Freeeの取引先に登録する
     */
    @AuraEnabled
    public static void account2Freee(Id accountId) {
        // 取引先情報を取得する
        Account acc = [select Id,Name,Phone,BillingPostalCode,BillingState,BillingCity,BillingStreet from Account where Id=:accountId];

        // 会社情報を取得する
        Integer companyId = getCompany();

        // Freeeの取引先に存在するかをチェックする
        if(!isExist(companyId, acc)) {
        // 登録されていなければ登録する
            registPartner(companyId, acc);
        }
    }

    /**
    * 会社情報を取得する
     */
    private static Integer getCompany() {    
        // 会社情報を取得する
        Http http = new Http();
        String path = 'callout:Freee/companies';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(path);
        req.setMethod('GET');

        HttpResponse res = http.send(req);
        // 会社情報が返ってきたらIIDと名称を設定する
        if (res.getStatusCode() == 200) {
            Map<String, Object> mapCompany = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            List<Object> lstCompany = (List<Object>)mapCompany.get('companies');
            if (lstCompany.size() == 0) {
                throw new OtherException('会社情報が取得できません');
            }
            else {
                return (Integer)((Map<String, Object>)lstCompany[0]).get('id');
            }
        }
        // エラーで返ってきたら例外をスローする
        else {
            throw new OtherException(getApiErrorMessage(res.getBody()));
        }
    }

    /**
    * 同じ取引先が存在するかをチェックする
    */
    private static Boolean isExist(Integer companyId, Account acc) {
        // 取引先名を指定して取引先情報を取得する
        Http http = new Http();
        String path = 'callout:Freee/partners';
        String parameters = 'company_id=' + companyId + '&';
        parameters += 'keyword=' + EncodingUtil.urlEncode(acc.Name, 'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(path + '?' + parameters);
        req.setMethod('GET');

        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200) {
            // 取引先情報が存在すればtrue、存在しなければfalseを返す
            Map<String, Object> mapBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            List<Object> lstBody = (List<Object>)mapBody.get('partners');
            if (lstBody.size() == 0) {
                return false;
            }
            else {
                return true;
            }
        }
        // エラーだったら例外をスローする
        else {
            throw new OtherException(getApiErrorMessage(res.getBody()));
        }
    }

    /**
    * 取引先をFreeeに登録する */
    private static void registPartner(Integer companyId, Account acc) {
        Http http = new Http();
        String path = 'callout:Freee/partners';
        String parameters = '{';
        parameters += '"company_id": ' + companyId + ',';
        parameters += '"name": "' + acc.Name + '",';
        parameters += '"long_name": "' + acc.Name + '",';
        parameters += '"default_title": "' + '御中' + '",';
        parameters += '"phone": "' + acc.Phone + '",';
        parameters += '"address_attributes": {';
        parameters += '"zipcode": "' + acc.BillingPostalCode + '",';
        Integer prefCode = getPrefCode(acc.BillingState);
        parameters += '"prefecture_code": ' + ((prefCode == null) ? 'null' : String.valueOf(prefCode)) + '';
        if(acc.BillingStreet != null) {
            parameters += ',';
            String[] billingStreet = acc.BillingStreet.split('\r\n');
            if(billingStreet.size() == 0) {
                parameters += '"street_name1": "' + acc.BillingCity + '",';
            }
            else {
                parameters += '"street_name1": "' + acc.BillingCity + billingStreet[0] + '"';
                if (billingStreet.size() >= 2) {
                    parameters += ',"street_name2": "' + billingStreet[1] + '"';
                }
            }
        }
        parameters += '}';
        parameters += '}';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(path);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(parameters);

        HttpResponse res = http.send(req);
        if (res.getStatusCode() != 201) {
            throw new OtherException(res.getBody());
        }
    }

    /**
    * エラーメッセージを設定する
     */
    private static String getApiErrorMessage(String body) {
        Map<String, Object> mapError = (Map<String, Object>)JSON.deserializeUntyped(body);
        List<Object> lstError = (List<Object>)(mapError.get('errors'));
        String errorMessage = 'Freee APIでエラーが発生しました\n';
        for(Object mapErrorContent : lstError) {
            List<Object> lstMessage = (List<Object>)((Map<String, Object>)mapErrorContent).get('messages');
            for(Object message : lstMessage) {
                errorMessage += message.toString() + '\n';
            }
        }

        return errorMessage;
    }

    /**
    * 都道府県コード変換
     */
    private static Integer getPrefCode(String prefName) {
        List<String> pref = new List<String> {
            '北海道',
            '青森県',
            '岩手県',
            '宮城県',
            '秋田県',
            '山形県',
            '福島県',
            '茨城県',
            '栃木県',
            '群馬県',
            '埼玉県',
            '千葉県',
            '東京都',
            '神奈川県',
            '新潟県',
            '富山県',
            '石川県',
            '福井県',
            '山梨県',
            '長野県',
            '岐阜県',
            '静岡県',
            '愛知県',
            '三重県',
            '滋賀県',
            '京都府',
            '大阪府',
            '兵庫県',
            '奈良県',
            '和歌山県',
            '鳥取県',
            '島根県',
            '岡山県',
            '広島県',
            '山口県',
            '徳島県',
            '香川県',
            '愛媛県',
            '高知県',
            '福岡県',
            '佐賀県',
            '長崎県',
            '熊本県',
            '大分県',
            '宮崎県',
            '鹿児島県',
            '沖縄県'
        };

        Integer prefCode = null;
        for(Integer i=0 ; i<pref.size() ; i++) {
            if(pref[i] == prefName) {
                prefCode = i;
                break;
            }
        }

        return prefCode;
    }
}
