import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  FirebaseFirestore billColection = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    // double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Hóa đơn"),
      ),
      body: StreamBuilder(
        stream: billColection.collection("Bill").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic> bills = snapshot.data!.docs;
            bills = bills.reversed.toList();
            return ListView.builder(
              itemCount: bills.length,
              itemBuilder: (context, index) {
                var bill = bills[index];
                return InkWell(
                  onTap: () {
                      AwesomeDialog(
                                btnOkText: "Có",
                                btnCancelText: "Quay lại",
                                context: context,
                                dialogType: DialogType.info,
                                animType: AnimType.rightSlide,
                                title: 'Thông báo',
                                desc: 'Bạn có muốn cập nhật hóa đơn đã thanh toán',
                                btnCancelOnPress: () {},
                                btnOkOnPress: () async {
                                  if(bill['is_paid']!=true){
                                     await billColection
                                      .collection("Bill")
                                      .doc(bill.id)
                                      .update({
                                        "is_paid":true
                                      });
                                  CherryToast.success(
                                    title: const Text("Cập nhật hóa đơn thành công"),
                                    // ignore: use_build_context_synchronously
                                  ).show(context);
                                  }else{
                                    CherryToast.warning(title: Text("Hóa đơn đã thanh toán"),).show(context);
                                  }
                                },
                              ).show();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    height: h * 0.2,
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: double.infinity,
                          width: h * 0.12,
                          decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10))),
                          child: Text(
                            bill['room_number'].toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Gap(5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Thuê theo: "),
                                
                                bill['is_rent_hour']
                                    ? const Text("Giờ",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold))
                                    : const Text("Ngày",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold))
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Bắt đầu: "),
                                Text(
                                    DateFormat('HH:mm - dd/MM/yyyy').format(
                                        DateTime.parse(bill['start_day'])),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Kết thúc: "),
                                Text(
                                    DateFormat('HH:mm - dd/MM/yyyy')
                                        .format(DateTime.parse(bill['end_day'])),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))
                              ],
                            )  ,  Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              
                                
                                bill['is_rent_hour']
                                    ?  Row(
                                      children: [
                                        const Text("Giá theo giờ: "),
                                        Text( convertMoney(bill['price_on_hour']),
                                            // ignore: prefer_const_constructors
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                    :   Row(
                                      children: [
                                         const Text("Giá theo ngày: "),
                                        Text(convertMoney(bill['price_on_day']),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    )
                              ],
                            ),                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Tổng tiền phải chả: "),
                                Text(
                                  convertMoney(bill['total_money']),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),        Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Thanh toán: "),
                                bill['is_paid'] ?  const Text(
                                 "Đã thanh toán",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,color: Colors.green)):const Text(
                                 "Chưa",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,color: Colors.red))
                              ]
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }  String convertMoney(int money) {
    return "${NumberFormat.decimalPattern('vi').format(money)}đ";
  }
}
