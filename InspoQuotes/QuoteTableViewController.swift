//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController {

    let productID = "com.bogdanorzea.InspoQuotes.PremiumQuotes"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        SKPaymentQueue.default().add(self)

        if werePremiumQuotesPurchased {
            showPremiumQuotes()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if werePremiumQuotesPurchased {
            return quotesToShow.count
        }

        return quotesToShow.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)

        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.accessoryType = .none
        } else {
            cell.textLabel?.text = "Get more quotes"
            cell.textLabel?.textColor = #colorLiteral(red: 0.1568627451, green: 0.6666666667, blue: 0.7529411765, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    // MARK: - Table view delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            buyPremiumQuotes()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - In-app purchase methods
    func buyPremiumQuotes() {
        // Check's if user can make payments
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("User cannot make payment")
        }
    }

    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - PaymentTransaction observer methods

extension QuoteTableViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                print("Transaction successful")

                showPremiumQuotes()

                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                if let error = transaction.error {
                    print("Transaction failed with error: \(error.localizedDescription)")
                }

                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored {
                print("Transaction restored")

                showPremiumQuotes()

                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }

    func showPremiumQuotes() {
        werePremiumQuotesPurchased = true
        quotesToShow.append(contentsOf: premiumQuotes)
        navigationItem.setRightBarButton(nil, animated: true)

        tableView.reloadData()
    }

    var werePremiumQuotesPurchased: Bool {
        get { UserDefaults.standard.bool(forKey: productID) }
        set { UserDefaults.standard.set(newValue, forKey: productID) }
    }
}
