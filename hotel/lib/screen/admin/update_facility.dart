import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hotel/provider/user.dart';
import 'package:provider/provider.dart';

class UpdateFacility extends StatefulWidget {
  const UpdateFacility({super.key, required this.facility});

  final dynamic facility;

  @override
  State<UpdateFacility> createState() => _UpdateFacilityState();
}

class _UpdateFacilityState extends State<UpdateFacility> {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  FirebaseFirestore roomColection = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    numberController.text = widget.facility['number'].toString();
    nameController.text = widget.facility['faciliti_name'];
    addressController.text = widget.facility['address'];
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final personelProvider = Provider.of<UserProvider>(context, listen: false);
    // double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                  labelText: 'Tên',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(20),
            const Gap(20),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(20),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: numberController,
              decoration: InputDecoration(
                  labelText: 'Cơ sở số :',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(20),
            MaterialButton(
              height: 40,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.blueAccent,
              minWidth: w * 0.8,
              onPressed: () async {
                await roomColection
                    .collection("Facility")
                    .doc(widget.facility.id)
                    .update({
                  "faciliti_name": nameController.text,
                  "address": addressController.text,
                  "number": int.parse(numberController.text),
                  "user_id": personelProvider.getUserId()
                });
                CherryToast.success(
                  title: const Text("Sửa thành công"),
                  // ignore: use_build_context_synchronously
                ).show(context);
              },
              child: const Text(
                "Sửa",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
