import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url2goweb/Utils/text.dart';

import '../Properties/Colors.dart';
import '../Properties/fontSizes.dart';
import '../Properties/fontWeights.dart';
import '../Providers/DateProvider.dart';
class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateProvider dateProvider = DateProvider();

  @override
  Widget build(BuildContext context) {
    dateProvider = Provider.of<DateProvider>(context);

    return Container(
      width: 380,
      height: 220,
      margin: EdgeInsets.only(left: 2, right: 2, top: 5),
      child: GestureDetector(
        onTap: () {
          _selectDate(context);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      textRoboto(
                        '${DateFormat('MMMM yyyy').format(dateProvider.currentDate)}',
                        selectedCategoryColor,
                        FontWeight.w400,
                        size14,
                      ),
                      DottedLine(
                        lineThickness: 1,
                        lineLength: 100,
                        dashColor: selectedCategoryColor,
                        dashGapLength: 2,
                        dashLength: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 170,
              width: 380,
              decoration: BoxDecoration(
                color: pageBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TableCalendar(
                availableGestures: AvailableGestures.none,

                calendarFormat: CalendarFormat.week,
                firstDay: DateTime.utc(2000),
                lastDay: DateTime.utc(2101),
                focusedDay: dateProvider.selectedDate,
                selectedDayPredicate: (day) {
                  return isSameDay(day, dateProvider.selectedDate);

                },

                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  formatButtonShowsNext: true,
                  leftChevronIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        dateProvider.updateSelectedDate(dateProvider.selectedDate.subtract(Duration(days: 7)));
                        dateProvider.updateSelectedDateGlobal(dateProvider.selectedDate.subtract(Duration(days: 7)));
                      });
                    },
                    child: Icon(Icons.arrow_back_ios),
                  ),
                  rightChevronIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        dateProvider.updateSelectedDate(dateProvider.selectedDate.add(Duration(days: 7)));
                        dateProvider.updateSelectedDateGlobal(dateProvider.selectedDate.add(Duration(days: 7)));
                      });
                    },
                    child: Icon(Icons.arrow_forward_ios),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  selectedTextStyle: TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                  defaultTextStyle: TextStyle(
                    color: textColor
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(
                    color: selectedCategoryColor,
                    fontWeight: w400,
                  ),
                  outsideDaysVisible: false,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: selectedCategoryColor,
                    fontWeight: w500,
                  ),
                  weekendStyle: TextStyle(
                    color: selectedCategoryColor,
                    fontWeight: w500,
                  ),
                ),
                onPageChanged: (newMonth) {
                  dateProvider.updateCurrentDate(newMonth);
                  dateProvider.updateSelectedDateGlobal(newMonth);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  dateProvider.updateSelectedDate(selectedDay);
                  dateProvider.updateSelectedDateGlobal(selectedDay);

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: dateProvider.selectedDate,
      firstDate: DateTime.utc(2000),
      lastDate: DateTime.utc(2101),
    ).then((picked) {
      if (picked != null && picked != dateProvider.selectedDate) {
        dateProvider.updateSelectedDate(picked);
        dateProvider.updateSelectedDateGlobal(picked);
      }
    });
  }
}
