import Foundation

protocol PaymentMethodsActionSheetDelegate: AnyObject {
    func addCardPaymentMethod()
    func setupApplePay()
    func setupPayPal()
    func setupGooglePay()
}