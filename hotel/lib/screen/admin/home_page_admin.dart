import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hotel/provider/user.dart';
import 'package:hotel/screen/admin/room.dart';
import 'package:hotel/screen/admin/update_facility.dart';
import 'package:lottie/lottie.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  FirebaseFirestore facilityColection = FirebaseFirestore.instance;
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
            final personelProvider =
        Provider.of<UserProvider>(context, listen: false);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: h * 0.07,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Khách sạn",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {
             showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            context: context,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(8),
                height: h * 0.6,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close)),
                    ),
                    textFieldAdd(nameController, "Tên khách sạn",TextInputType.text),
                    const Gap(10),
                    textFieldAdd(addressController, "Địa chỉ",TextInputType.text),
                    const Gap(10),
                    textFieldAdd(numberController, "Cơ sở số",TextInputType.number),
                    const Gap(20),
                    MaterialButton(
                      onPressed: () {
                        AwesomeDialog(
                          btnOkText: "Có",
                          btnCancelText: "Quay lại",
                          context: context,
                          dialogType: DialogType.info,
                          animType: AnimType.rightSlide,
                          title: 'Thông báo',
                          desc: 'Bạn có muốn thêm cơ sở',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                         await  facilityColection.collection("Facility").add({
                              "faciliti_name":nameController.text,
                              "address":addressController.text,
                              "number":numberController.text,
                              "user_id":personelProvider.getUserId()
                            });
                            setState(() {
                              nameController.clear();
                              addressController.clear();
                              numberController.clear();
                            
                            });
                               CherryToast.success(
                  title: const Text("Thêm cơ sở thành công"),
                // ignore: use_build_context_synchronously
                ).show(context);
                          },
                        ).show();
                      },
                      minWidth: w * 0.9,
                      height: 50,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: const Text(
                        "Thêm cơ sở",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
          }, icon: Icon(Icons.add))
        ],
      ),
      body: StreamBuilder(
        stream: facilityColection
            .collection("Facility")
            .orderBy("number", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var facilities = snapshot.data!.docs;
            if (facilities.isNotEmpty) {
              return ListView.builder(
                itemCount: facilities.length,
                itemBuilder: (context, index) {
                  var facility = facilities[index];
                  return InkWell(
                    onLongPress: () {
                      NDialog(
                        dialogStyle: DialogStyle(titleDivider: true),
                        title: const Text("Thông báo"),
                        content: const Text("Mời bạn chọn chức năng"),
                        actions: <Widget>[
                          TextButton(
                              child: const Text("Quay lại"),
                              onPressed: () => Navigator.pop(context)),
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
                                    await facilityColection
                                        .collection("Facility")
                                        .doc(facility.id)
                                        .delete();
                                    CherryToast.success(
                                      title: const Text("Xóa cơ sở thành công"),
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
                                          UpdateFacility(facility: facility),
                                    ));
                              }),
                        ],
                      ).show(context);
                    },
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomScreen(
                              facilitiName: facility.id,
                            ),
                          ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
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
                      margin:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/hotel_${index + 1}.png"),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    facility['faciliti_name'],
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("${facility['address']}",
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 81, 124, 81))),
                                  Row(
                                    children: [
                                      const Text("Cơ sở số: "),
                                      Text("${facility['number']}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text("Chưa có phòng"));
            }
          } else {
            return Center(
                child: Lottie.asset("assets/lottie/loading.json",
                    width: 120, height: 120));
          }
        },
      ),
    );
  }
   Widget textFieldAdd(TextEditingController controller, String label,TextInputType type) {
    return TextField(
      keyboardType: type,
      controller: controller,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          labelText: label),
    );
  }
}
