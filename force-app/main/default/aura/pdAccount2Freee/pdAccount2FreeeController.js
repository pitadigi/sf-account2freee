({
    doRegist : function(component, event, helper) {
        // 処理中フラグを設定する
        component.set("v.isProgress", true);

        // Freeeに取引先を登録する
        const account2Freee = component.get("c.account2Freee");
        account2Freee.setParams({
            "accountId": component.get("v.recordId")
        });

        account2Freee.setCallback(this, (res) => {
            const state = res.getState();
            if (state === "SUCCESS") {
                // 処理完了フラグをセットする
                component.set("v.isDone", true);
            }
            else {
                component.set("v.errorMessage", state);
                component.set("v.isError", true);
            }
            // 処理中フラグを初期化する
            component.set("v.isProgress", false);
        })

        $A.enqueueAction(account2Freee);
    }
})
