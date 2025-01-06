class Convertions {
  static String gradeToAlpha(double grade) {
    if (grade >= 90) {
      return "A+";
    } else if (grade >= 85) {
      return "A";
    } else if (grade >= 80) {
      return "A-";
    } else if (grade >= 75) {
      return "B+";
    } else if (grade >= 70) {
      return "B";
    } else if (grade >= 65) {
      return "C+";
    } else if (grade >= 60) {
      return "C";
    } else if (grade >= 55) {
      return "D+";
    } else if (grade >= 50) {
      return "D";
    } else if (grade >= 40) {
      return "E";
    } else {
      return "F";
    }
  }

  static double gradeToGpa(double grade) {
    if (grade >= 90) {
      return 4.0;
    } else if (grade >= 80) {
      return 3.7;
    } else if (grade >= 70) {
      return 3.0;
    } else if (grade >= 60) {
      return 2.0;
    } else if (grade >= 50) {
      return 1.0;
    } else {
      return 0.0;
    }
  }

  static String getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "Unknown";
    }
  }

  static int getDayOfWeekNumber(String day) {
    switch (day) {
      case "Monday":
        return 1;
      case "Tuesday":
        return 2;
      case "Wednesday":
        return 3;
      case "Thursday":
        return 4;
      case "Friday":
        return 5;
      case "Saturday":
        return 6;
      case "Sunday":
        return 7;
      default:
        return 0;
    }
  }
}
