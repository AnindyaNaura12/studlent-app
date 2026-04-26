class RegisterModel {
  String username;
  String phoneNumber;
  String password;
  String productInterest;
  bool agreeToTerms;

  RegisterModel({
    this.username = '',
    this.phoneNumber = '',
    this.password = '',
    this.productInterest = '',
    this.agreeToTerms = false,
  });
}