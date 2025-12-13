
// class TipsDoctorScreen extends StatefulWidget {
//   const TipsDoctorScreen({super.key});

//   @override
//   State<TipsDoctorScreen> createState() => _TipsDoctorScreenState();
// }

// class _TipsDoctorScreenState extends State<TipsDoctorScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.grey[200],
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Text(
//                     'Tips',
//                     style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                   ),
//                   const Spacer(),
//                   Icon(Icons.lightbulb, color: ColorsApp().primaryColor),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 5),
//                 child: Divider(color: Colors.grey[300], thickness: 1.5),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   physics: const BouncingScrollPhysics(),
//                   itemCount: 8,
//                   itemBuilder: (context, index) {
//                     return TipsDoctorCard();
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class TipsDoctorCard extends StatelessWidget {
//   const TipsDoctorCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ListTile(
//           contentPadding: EdgeInsets.zero,
//           horizontalTitleGap: 10,
//           title: const Text(
//             'Wael',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           subtitle: Row(
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.medical_services_outlined,
//                     size: 18,
//                     color: ColorsApp().primaryColor,
//                   ),
//                   SizedBox(width: 5),
//                   Text(
//                     'Music Therapist',
//                     style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//               Spacer(),
//               Padding(
//                 padding: const EdgeInsets.only(right: 30),
//                 child: Row(
//                   children: [
//                     Text(
//                       '2m ago',
//                       style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           leading: Container(
//             width: 55,
//             height: 60,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.grey[300],
//               image: const DecorationImage(
//                 image: AssetImage('assets/images/doctors4.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           'Every child with autism is unique. Focus on understanding their individual strengths and challenges rather than comparing them to others. Celebrate every small progress — it means a lot.',
//           style: TextStyle(fontSize: 16),
//           overflow: TextOverflow.ellipsis,
//           maxLines: 2,
//         ),
//         const SizedBox(height: 10),
//         Container(
//           width: double.infinity,
//           height: 200,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: Colors.grey[300],
//             image: const DecorationImage(
//               image: NetworkImage(
//                 'https://www.theyarethefuture.co.uk/wp-content/uploads/2023/07/coding-boy-1024x576.jpg',
//               ),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 30),
//           child: Divider(color: Colors.grey[300], thickness: 1.5),
//         ),
//       ],
//     );
//   }
// }
