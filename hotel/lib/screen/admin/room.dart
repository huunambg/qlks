import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hotel/screen/admin/add_bill_day.dart';
import 'package:hotel/screen/admin/add_bill_hour.dart';
import 'package:hotel/screen/admin/add_personnel.dart';
import 'package:hotel/screen/admin/add_room.dart';
import 'package:hotel/screen/admin/update_room.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.facilitiName});
  final String facilitiName;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  FirebaseFirestore roomColection = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    // double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [ IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPersonnel(
                        facilityId: widget.facilitiName,
                      ),
                    ));
              },
              icon: const Icon(Icons.person_2_outlined)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRoomScreen(
                        facilityId: widget.facilitiName,
                      ),
                    ));
              },
              icon: const Icon(Icons.holiday_village))
              
        ],
        title: const Text("Danh sách phòng"),
      ),
      body: StreamBuilder(
        stream: roomColection
            .collection("Room")
            .where('facility_id', isEqualTo: widget.facilitiName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic> rooms = snapshot.data!.docs;
            rooms = rooms.reversed.toList();
            //  print(rooms);
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: rooms.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemBuilder: (context, index) {
                var room = rooms[index];
                return InkWell(
                  onLongPress: () {
                    NDialog(
                      dialogStyle: DialogStyle(titleDivider: true),
                      title: const Text("THông báo"),
                      content: const Text("Mời bạn chọn chức năng phòng"),
                      actions: <Widget>[
                        TextButton(
                            child: const Text("Xóa"),
                            onPressed: () {
                              Navigator.pop(context);
                              AwesomeDialog(
                                btnOkText: "Có",
                                btnCancelText: "Quay lại",
                                context: context,
                                dialogType: DialogType.info,
                                animType: AnimType.rightSlide,
                                title: 'Thông báo',
                                desc: 'Bạn có muốn xóa cơ sở ',
                                btnCancelOnPress: () {},
                                btnOkOnPress: () async {
                                  await roomColection
                                      .collection("Room")
                                      .doc(room.id)
                                      .delete();
                                  CherryToast.success(
                                    title: const Text("Xóa phòng thành công"),
                                    // ignore: use_build_context_synchronously
                                  ).show(context);
                                },
                              ).show();
                            }),
                        TextButton(
                            child: const Text("Sửa"),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateRoom(room: room)));
                            }),
                        TextButton(
                            child: const Text("Quay lại"),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ).show(context);
                  },
                  onTap: () {
                    NDialog(
                      dialogStyle: DialogStyle(titleDivider: true),
                      title: const Text("Thông báo"),
                      content: const Text("Mời bạn chọn thuê phòng"),
                      actions: <Widget>[
                        TextButton(
                            child: const Text("Theo giờ"),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddBillHour(room: room),
                                  ));
                            }),
                        TextButton(
                          child: const Text("Theo ngày"),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddBillDay(room: room),
                                ));
                          },
                        ),
                        TextButton(
                            child: const Text("Quay lại"),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ).show(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: h * 0.14,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            room['room_number'].toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8, left: 8, right: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text("Giá theo giờ: ",
                                      style: TextStyle(fontSize: 12)),
                                  Text(convertMoney(room['price_on_hour']),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("Giá theo ngày: ",
                                      style: TextStyle(fontSize: 12)),
                                  Text(convertMoney(room['price_on_day']),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              // ignore: prefer_const_constructors
                              Gap(5),
                              room['is_vip']
                                  ? const Center(
                                      child: Text(
                                      "VIP",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ))
                                  : Container()
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
                child: Lottie.asset("assets/lottie/loading.json",
                    width: 120, height: 120));
          }
        },
      ),
    );
  }

  String convertMoney(int money) {
    return "${NumberFormat.decimalPattern('vi').format(money)}đ";
  }

  Widget textFieldBill(
      TextEditingController controller, String label, TextInputType type) {
    return TextField(
      keyboardType: type,
      controller: controller,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          labelText: label),
    );
  }
}
