//
//  IAPHandler.swift
//  Remoku Remote Control
//
//  Created by Jack Weber on 10/25/20.
//  Copyright © 2020 Jack Weber. All rights reserved.
//

import UIKit
import StoreKit

class IAPHandler: NSObject, SKProductsRequestDelegate {
    enum IAPHandlerError: Error {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
    }
    
    static let shared = IAPHandler()
    let productIds: Set<String> = ["com.brick.Remoku.Pro", "Pro", "com.brick.Pro"]
    var purchasedProductIdentifiers: Set<String> = []
    var onReceiveProductsHandler: ((Result<[SKProduct], IAPHandlerError>) -> Void)?
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        if products.count > 0 {
            onReceiveProductsHandler?(.success(products))
        } else {
            onReceiveProductsHandler?(.failure(.noProductsFound))
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }
    
    public func restorePurchases() {
      SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPHandlerError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler
        
        print("[IAPHandler]: GetProducts started.")
     
        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: productIds)
     
        // Set self as the its delegate.
        request.delegate = self
     
        // Make the request.
        request.start()
    }
    
    public override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    public func buyProduct(_ product: SKProduct) {
      print("Buying \(product.productIdentifier)...")
      let payment = SKPayment(product: product)
      SKPaymentQueue.default().add(payment)
    }
}

extension IAPHandler.IAPHandlerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
        case .noProductsFound: return "No In-App Purchases were found."
        case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
        case .paymentWasCancelled: return "In-App Purchase process was cancelled."
        }
    }
}

extension IAPHandler: SKPaymentTransactionObserver {
 
  public func paymentQueue(_ queue: SKPaymentQueue,
                           updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .purchased:
        complete(transaction: transaction)
        break
      case .failed:
        fail(transaction: transaction)
        break
      case .restored:
        restore(transaction: transaction)
        break
      case .deferred:
        break
      case .purchasing:
        break
      }
    }
  }
 
  private func complete(transaction: SKPaymentTransaction) {
    print("complete...")
    deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }
 
  private func restore(transaction: SKPaymentTransaction) {
    guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
 
    print("restore... \(productIdentifier)")
    deliverPurchaseNotificationFor(identifier: productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }
 
  private func fail(transaction: SKPaymentTransaction) {
    print("fail...")
    if let transactionError = transaction.error as NSError?,
      let localizedDescription = transaction.error?.localizedDescription,
        transactionError.code != SKError.paymentCancelled.rawValue {
        print("Transaction Error: \(localizedDescription)")
      }

    SKPaymentQueue.default().finishTransaction(transaction)
  }
 
  private func deliverPurchaseNotificationFor(identifier: String?) {
    guard let identifier = identifier else { return }
    purchasedProductIdentifiers.insert(identifier)
    UserDefaults.standard.set(true, forKey: "Pro")
    NotificationCenter.default.post(name: NSNotification.Name("IAPHandlerPurchaseNotification"), object: identifier)
  }
}
