import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms_pptik/src/data/models/materi_model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lms_pptik/src/extensions/int_extension.dart';
import 'package:lms_pptik/src/extensions/string_extension.dart';

import '../../utils/helper/function_helper/function_helper.dart';

class MateriDetailPage extends StatefulWidget {
  const MateriDetailPage(
      {super.key, required this.materis, required this.selectedIndex});

  final int selectedIndex;
  final List<MateriModel> materis;

  @override
  State<MateriDetailPage> createState() => _MateriDetailPageState();
}

class _MateriDetailPageState extends State<MateriDetailPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.selectedIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () {
                  _pageController.previousPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                },
                child: const Icon(Icons.arrow_back_ios),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                },
                child: const Icon(Icons.arrow_forward_ios),
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(widget.materis[_currentIndex].name!.decodeHtml()),
      ),
      body: PageView.builder(
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.materis.length,
          controller: _pageController,
          itemBuilder: (context, index) {
            return Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    widget.materis[index].summary != null
                        ? Html(data: widget.materis[index].summary)
                        : const SizedBox(),
                    ExpansionTile(
                      initiallyExpanded: true,
                      title: const Text(
                        'Modul',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [buildModTile(index)],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget buildModTile(int index) {
    return ListView.separated(
      separatorBuilder: (context, i) => const Divider(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.materis[index].modules!.length,
      itemBuilder: (context, i) {
        final mod = widget.materis[index].modules![i];
        switch (mod.modname) {
          case 'assign':
            return Card(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {},
                    leading: const Icon(
                      Icons.assignment,
                      size: 40,
                      color: Colors.amber,
                    ),
                    title: Text(
                      mod.name!.decodeHtml(),
                    ),
                  ),
                  mod.description != null
                      ? Html(data: mod.description!)
                      : const SizedBox(),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 20, left: 20, bottom: 10),
                    child: Column(
                      children: [
                        if (mod.dates!.isNotEmpty)
                          for (DateModel date in mod.dates!)
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, size: 20),
                                Text.rich(
                                  TextSpan(
                                    text: date.label!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(fontWeight: FontWeight.w600),
                                    children: [
                                      TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                        text:
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    date.timestamp! * 1000)
                                                .toString()
                                                .formatDate(),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  )
                ],
              ),
            );
          case 'forum':
            return Card(
              child: ListTile(
                onTap: () {},
                leading:
                    const Icon(Icons.forum, size: 40, color: Colors.orange),
                title: Text(
                  mod.name!.decodeHtml(),
                ),
              ),
            );
          case 'lesson':
            return Card(
              child: ListTile(
                onTap: () {},
                leading: mod.modicon != null
                    ? const SizedBox(
                        height: 40,
                        width: 40,
                        child: Icon(
                          Icons.play_lesson,
                          size: 40,
                          color: Colors.indigo,
                        ))
                    : const Icon(Icons.file_copy, size: 40),
                title: Text(
                  mod.name!.decodeHtml(),
                ),
              ),
            );
          case 'resource':
            return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mod.contents!.length,
                itemBuilder: (context, index) {
                  final content = mod.contents![index];
                  return Card(
                    child: ListTile(
                      subtitle:
                          Text('${content.filesize?.formatFileSize() ?? '-'} '),
                      trailing: IconButton.filled(
                          onPressed: () {
                            // context.read<ViewResourceBloc>().add(ModResourceEvent.viewResource(mod.c));
                            FunctionHelper.downloadFileHandler(
                                context,
                                content.filename ?? '',
                                (content.fileurl ?? '')
                                    .replaceAll('?forcedownload=1', ''));
                          },
                          icon: const Icon(Icons.download)),
                      leading: mod.modicon != null
                          ? SizedBox(
                              height: 40,
                              width: 40,
                              child: SvgPicture.asset('assets/img/file.svg'))
                          : const Icon(Icons.file_copy, size: 40),
                      title: Text(
                        mod.name!.decodeHtml(),
                      ),
                    ),
                  );
                });
          case 'quiz':
            return Column(
              children: [
                Card(
                  child: InkWell(
                    onTap: mod.uservisible! == true ? () {} : null,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            trailing: mod.uservisible! == true
                                ? const SizedBox()
                                : const Icon(Icons.lock, color: Colors.red),
                            leading: const Icon(
                              Icons.task,
                              size: 40,
                              color: Colors.cyan,
                            ),
                            title: Text(
                              mod.name!.decodeHtml(),
                            ),
                          ),
                          Column(
                            children: [
                              if (mod.dates!.isNotEmpty)
                                for (DateModel date in mod.dates!)
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month,
                                          size: 20),
                                      Text.rich(
                                        TextSpan(
                                          text: date.label!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600),
                                          children: [
                                            TextSpan(
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium,
                                              text: DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          date.timestamp! *
                                                              1000)
                                                  .toString()
                                                  .formatDate(),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                if (mod.availabilityinfo != null)
                  Html(data: mod.availabilityinfo),
                if (mod.description != null) Html(data: mod.description),
              ],
            );
          case 'label':
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mod.name!.decodeHtml(),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 25,
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          'Tandai Selesai',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          case 'workshop':
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        log(mod.uservisible!.toString());
                      },
                      leading: Icon(
                        Icons.people_alt_rounded,
                        size: 40,
                        color: mod.uservisible! == true
                            ? Colors.red.shade400
                            : Colors.grey,
                      ),
                      title: Text(
                        mod.name!.decodeHtml(),
                      ),
                      trailing: !mod.completiondata!['uservisible']
                          ? const Icon(Icons.lock)
                          : null,
                      subtitle: !mod.completiondata!['uservisible']
                          ? null
                          : SizedBox(
                              height: 25,
                              width: 100,
                              child: OutlinedButton(
                                onPressed: () {},
                                child: Text(
                                  'Tandai Selesai',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    mod.dates!.isNotEmpty
                        ? Column(
                            children: [
                              if (mod.dates!.isNotEmpty)
                                for (DateModel date in mod.dates!)
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month,
                                          size: 20),
                                      Text.rich(
                                        TextSpan(
                                          text: date.label!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600),
                                          children: [
                                            TextSpan(
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium,
                                              text: DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          date.timestamp! *
                                                              1000)
                                                  .toString()
                                                  .formatDate(),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                            ],
                          )
                        : const SizedBox()
                  ],
                ),
              ),
            );
          default:
        }
        return null;
      },
    );
  }
}
