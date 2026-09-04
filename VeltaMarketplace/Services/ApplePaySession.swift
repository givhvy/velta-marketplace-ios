import PassKit

enum VeltaApplePay {
    static let merchantID = "merchant.io.velta.marketplace"

    static var canMakePayments: Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }
}

final class ApplePaySession: NSObject, PKPaymentAuthorizationControllerDelegate, @unchecked Sendable {
    var onAuthorized: (@MainActor () async -> Void)?
    var onUnavailable: (@MainActor () -> Void)?
    var onCancel: (@MainActor () -> Void)?

    private var controller: PKPaymentAuthorizationController?
    private var authorized = false

    @MainActor
    func start(amount: Double, label: String) {
        authorized = false
        let request = PKPaymentRequest()
        request.merchantIdentifier = VeltaApplePay.merchantID
        request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        request.merchantCapabilities = [.threeDSecure, .debit, .credit]
        request.countryCode = "US"
        request.currencyCode = "USD"
        let total = NSDecimalNumber(value: (amount * 100).rounded() / 100)
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: label, amount: total),
            PKPaymentSummaryItem(label: "Velta", amount: total, type: .final),
        ]

        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        self.controller = controller
        controller.present { [weak self] presented in
            guard let self, !presented else { return }
            Task { @MainActor in
                self.onUnavailable?()
            }
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        let didPay = authorized
        controller.dismiss { [weak self] in
            self?.controller = nil
            if !didPay {
                Task { @MainActor in
                    self?.onCancel?()
                }
            }
        }
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        _ = payment
        authorized = true
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        Task { @MainActor in
            await self.onAuthorized?()
        }
    }
}
