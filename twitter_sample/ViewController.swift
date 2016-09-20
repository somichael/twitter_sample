//
//  ViewController.swift
//  twitter_sample
//
//  Created by NAGAMINE HIROMASA on 2015/08/16.
//  Copyright (c) 2015年 Hiromasa Nagamine. All rights reserved.
//

import UIKit
import Accounts

class ViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!
    var accountStore = ACAccountStore()   // 追加
    var twAccount = ACAccount()           // 追加
    var accounts = [ACAccount]()          // 追加

    // ログイン画面のローディング(ライフサイクルメソッド)
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    // メモリーが不足した時にOSから呼ばれる(ライフサイクルメソッド)
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // ログインボタンを押すと呼ばれる(ユーザーアクションメソッド)
    @IBAction func tappedLoginButton(sender: AnyObject) {
        
        self.getTwitterAccountsFromDevice()
        
    }
    
    // 追加
    /* iPhoneに設定したTwitterアカウントの情報を取得する */
    func getTwitterAccountsFromDevice(){
        
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted:Bool, aError:NSError?) -> Void in
            
            // アカウント取得に失敗したとき
            if let error = aError {
                print("Error! - \(error)")
                return
            }
            
            // アカウント情報へのアクセス権限がない時
            if !granted {
                print("Cannot access to account data")
                return
            }
            
            // アカウント情報の取得に成功
            let a = self.accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            if a.count == 0 {
                print("error! 設定画面からアカウントを設定してください")
                return
            }
            self.accounts = self.accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            self.showAndSelectTwitterAccountWithSelectionSheets()
        }
    }
    
    // 追加
    /* iPhoneに設定したTwitterアカウントの選択画面を表示する */
    func showAndSelectTwitterAccountWithSelectionSheets() {
        
        // アクションシートの設定
        let alertController = UIAlertController(title: "Select Account", message: "Please select twitter account", preferredStyle: .ActionSheet)
        
        for account in accounts {
            
            alertController.addAction(UIAlertAction(title: account.username, style: .Default, handler: { (action) -> Void in
                // 選択したアカウントをtwAccountに保存
                self.twAccount = account
                self.performSegueWithIdentifier("segueTimelineViewController", sender: nil)
            }))
            
        }
        
        // キャンセルボタンは何もせずにアクションシートを閉じる
        let CanceledAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(CanceledAction)
        
        // アクションシート表示
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /* アカウントを選択したあと、タイムライン画面へ遷移する処理 */
    func showAndSelectTwitterAccountWithSelectionSheets(accounts: [ACAccount]) {
        /* 省略 */
    }
    
    // TimelineViewControllerを表示する際に選択したアカウントを渡す
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueTimelineViewController" {
            let vc = segue.destinationViewController as! TimelineViewController
            vc.twAccount = self.twAccount
        }
    }

}

