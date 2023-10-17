import 'package:app/util/common_util.dart';
import 'package:flutter/material.dart';

class UserActivityItemView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final Color highlightColor;
  final Color shadeColor;
  final double progressValue;

  const UserActivityItemView({
    Key? key,
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.highlightColor,
    required this.shadeColor,
    required this.progressValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          16, 5, 16, 5), // Reduziert die vertikale Höhe
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 15), // vertikale Anpassung
      decoration: CommonUtil.getRectangleBoxDecoration(Colors.white70, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            color: shadeColor,
            child: Icon(
              icon,
              size: 35,
              color: highlightColor,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        if (title ==
                            "Schritt") // Falls title == step, dann zeige info icon
                          IconButton(
                            icon: const Icon(Icons.info),
                            color: highlightColor,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Schritte nach Gehgeschwindigkeit'),
                                    content: RichText (
                                      text: const TextSpan (
                                        children: <TextSpan> [
                                          TextSpan(
                                            text: "Für einen Menschen definiert die durchschnittliche Gehgeschwindigkeit die Anzahl der Schritte wie folgt:\n\n",
                                            style: TextStyle(color: Colors.black87),
                                          ),
                                          TextSpan(
                                            text:
                                                "Schnell: 100-119 Schritte/min\n"
                                                "Medium: 80-99 Schritte/min\n"
                                                "Langsam: 60-79 Schritte/min\n\n\n",
                                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: "Diese Informationen beruhen auf einer wissenschaftlichen Untersuchung von:\n\n",
                                            style: TextStyle(color: Colors.black87),
                                          ),
                                          TextSpan(
                                            text: "Tudor-Locke C, Han H, Aguiar EJ, et alHow fast is fast enough? Walking cadence (steps/min) as a practical estimate of intensity in adults: a narrative reviewBritish Journal of Sports Medicine 2018;52:776-788.",
                                            style: TextStyle(color: Colors.black87, fontStyle: FontStyle.italic),
                                          ),
                                        ]
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Schließen', style: TextStyle(color: Colors.orange),),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                    Text(
                      subTitle,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    color: highlightColor.withAlpha(200),
                    backgroundColor: shadeColor,
                    minHeight: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
