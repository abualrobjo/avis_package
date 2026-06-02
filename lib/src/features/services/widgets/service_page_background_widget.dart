import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class ServicePageBackgroundWidget extends StatelessWidget {
  const ServicePageBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const ImageWidget(name: 'home-background', fit: BoxFit.fill),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(color: context.colors.secondaryContainer),
        ),
      ],
    );
  }
}
