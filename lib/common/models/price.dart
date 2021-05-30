class Price {
  double total = 0;
  double discountAmt = 0;
  double finalAmt = 0;

  Price(this.total, this.discountAmt, this.finalAmt);

  String dispTotal() {
    return total.ceil().toString();
  }
  
  String dispDiscAmt() {
    return discountAmt.ceil().toString();
  }
  
  String dispFinalAmt() {
    return finalAmt.ceil().toString();
  }
}
