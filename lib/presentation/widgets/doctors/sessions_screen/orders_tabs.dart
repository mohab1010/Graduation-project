import 'package:wesal/logic/services/colors_app.dart';
import 'package:flutter/material.dart';

class OrdersTabs extends StatefulWidget {
  final void Function(String) onTabChange;
  const OrdersTabs({required this.onTabChange, super.key});

  @override
  State<OrdersTabs> createState() => _OrdersTabsState();
}

class _OrdersTabsState extends State<OrdersTabs> {
  int selectedIndex = 0;

  // القيم اللي موجودة في الـ ENUM بالـ DB (مثل ما شفنا)
  final tabs = ["pending", "accepted", "rejected", "completed", "canceled"];

  String displayStatus(String status) {
    switch (status) {
      case "pending":
        return "Pending";
      case "accepted":
        return "Accepted";
      case "rejected":
        return "Rejected";
      case "completed":
        return "Completed";
      case "canceled":
        return "Cancelled";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200], // الخلفية الرمادية
        borderRadius: BorderRadius.circular(25),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onTabChange(tabs[index]); // مهم
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              // margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorsApp().primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  displayStatus(tabs[index]),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black45,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
