import 'package:get/get.dart';
import 'package:teacher_app_edubloom/infrastructures/routes/page_constants.dart';
import '../../binding/AddResultBinding.dart';
import '../../binding/AttendanceBinding.dart';
import '../../binding/ClassWiseFeeStructureBinding.dart';
import '../../binding/DailyActivityBinding.dart';
import '../../binding/DailyCollectionClassWiseBinding.dart';
import '../../binding/DailyCollectionHeadWiseBinding.dart';
import '../../binding/Daycareattendancebinding.dart';
import '../../binding/FeeDailyCollectionBinding.dart';
import '../../binding/FeeTypeReportBinding.dart';
import '../../binding/FeedetailsStudentReportBinding.dart';
import '../../binding/StaffDetailsBinding.dart';
import '../../binding/StudentListBinding.dart';
import '../../binding/TeacherDesignationBinding.dart';
import '../../binding/TransferCertificateReportsBinding.dart';
import '../../binding/ViewGirlsBoysReportbinding.dart';
import '../../binding/View_AttendanceBinding.dart';
import '../../binding/activieybindingmaster.dart';
import '../../binding/activitybinding.dart';
import '../../binding/add_discount_binding.dart';
import '../../binding/add_expenses_binding.dart';
import '../../binding/add_products_binding.dart';
import '../../binding/addroutemasterbinding.dart';
import '../../binding/addstudentbinding.dart';
import '../../binding/addstudentdaycarebinding.dart';
import '../../binding/all_fee_report_binding.dart';
import '../../binding/appdrawer_screen_binding.dart';
import '../../binding/behaviourbinding.dart';
import '../../binding/change_password_binding.dart';
import '../../binding/class_binding.dart';
import '../../binding/class_teacher_binding.dart';
import '../../binding/communicationbinding.dart';
import '../../binding/createandmapcategory.dart';
import '../../binding/dashboard_screen_binding.dart';
import '../../binding/day_care_binding.dart';
import '../../binding/day_care_fee_master.dart';
import '../../binding/daycare_feepayment_view_binding.dart';
import '../../binding/descriptors_binding.dart';
import '../../binding/discount_list_master_binding.dart';
import '../../binding/event_binding.dart';
import '../../binding/expenses_add_category_binding.dart';
import '../../binding/fee_head_master_binding.dart';
import '../../binding/fee_payment_details_binding.dart';
import '../../binding/fee_student_binding_reports.dart';
import '../../binding/feedurationbinding.dart';
import '../../binding/fees_binding.dart';
import '../../binding/feesbindingmaster.dart';
import '../../binding/feetypemaster.dart';
import '../../binding/forgot_password_binding.dart';
import '../../binding/foundational_skills_binding.dart';
import '../../binding/galleryvideobinding.dart';
import '../../binding/grade_master_binding.dart';
import '../../binding/home_work_binding.dart';
import '../../binding/login_screen_binding.dart';
import '../../binding/map_descriptors_binding.dart';
import '../../binding/map_foundational_skills_binding.dart';
import '../../binding/mapcategory.dart';
import '../../binding/master_certificate_binding.dart';
import '../../binding/master_daily_activity_binding.dart';
import '../../binding/master_expenses_binding.dart';
import '../../binding/master_product_binding.dart';
import '../../binding/masterbinding.dart';
import '../../binding/mealbinding.dart';
import '../../binding/note_binding.dart';
import '../../binding/notification_binding.dart';
import '../../binding/parent_id_binding.dart';
import '../../binding/pay_daycare_binding.dart';
import '../../binding/payment_master_binding.dart';
import '../../binding/product_quantity_binding.dart';
import '../../binding/profile_screen_binding.dart';
import '../../binding/registerbinding.dart';
import '../../binding/report_card_binding.dart';
import '../../binding/reportsbinding.dart';
import '../../binding/result_view_binding.dart';
import '../../binding/routepointmaster_binding.dart';
import '../../binding/sectionbinding.dart';
import '../../binding/session_binding.dart';
import '../../binding/splash_screen_bindings.dart';
import '../../binding/staff_detail_binding.dart';
import '../../binding/staffattendancebinding.dart';
import '../../binding/stafftypebinding.dart';
import '../../binding/staffviewbinding.dart';
import '../../binding/stationary_fee print_binding.dart';
import '../../binding/stationary_fee_action_binding.dart';
import '../../binding/stationary_fee_student_binding.dart';
import '../../binding/stationary_inventory_binding.dart';
import '../../binding/student_binding.dart';
import '../../binding/student_wise_fee_binding.dart';
import '../../binding/student_wise_yearly_report_binding.dart';
import '../../binding/subject_binding.dart';
import '../../binding/subject_class_assign_binding.dart';
import '../../binding/submitFeeB.dart';
import '../../binding/syllabus_binding.dart';
import '../../binding/tc_certificate_bindingdownload.dart';
import '../../binding/teacher_add_binding.dart';
import '../../binding/teacher_attendance_binding.dart';
import '../../binding/teacher_detail_binding.dart';
import '../../binding/teacher_subject_binding.dart';
import '../../binding/teacherbinding.dart';
import '../../binding/term_result_binding.dart';
import '../../binding/totalstudentbinding.dart';
import '../../binding/transport_fee_binding.dart';
import '../../binding/user_access_binding.dart';
import '../../binding/user_details_binding.dart';
import '../../binding/view_curriculum.dart';
import '../../binding/view_expenses_binding.dart';
import '../../binding/view_teacher_attendance_binding.dart';
import '../../binding/viewdaycareamodel.dart';
import '../../binding/viewdaycareattendance_binding.dart';
import '../../binding/viewstaffattendance.dart';
import '../../binding/viewtransction.dart';
import '../../pages/AddResultMasterScreen.dart';
import '../../pages/AttendancePage.dart';
import '../../pages/ClassWiseFeeStructureScreen.dart';
import '../../pages/DailyActivityScreen.dart';
import '../../pages/DailyCollectionHeadWiseScreen.dart';
import '../../pages/Daycaretakeattendanceview.dart';
import '../../pages/DobCertificateScreen.dart';
import '../../pages/FeeDailyCollectionScreen.dart';
import '../../pages/FeeTypeReportScreen.dart';
import '../../pages/StaffDetailsScreen.dart';
import '../../pages/Teacherview.dart';
import '../../pages/TransferCertificateReportsScreen.dart';
import '../../pages/ViewGirlsBoysReportscreen.dart';
import '../../pages/View_AttendancePage.dart';
import '../../pages/activityview.dart';
import '../../pages/activityviewmaster.dart';
import '../../pages/add_discount_screen.dart';
import '../../pages/add_expenses.dart';
import '../../pages/add_products_screen.dart';
import '../../pages/adddaycarestudentview.dart';
import '../../pages/addroutemasterscreen.dart';
import '../../pages/addstudentmaster.dart';
import '../../pages/all_fee_report_screen.dart';
import '../../pages/attendance_details_day_care_view.dart';
import '../../pages/behaviourview.dart';
import '../../pages/change_password_screen.dart';
import '../../pages/class_screen.dart';
import '../../pages/class_teacher_screen.dart';
import '../../pages/communicationview.dart';
import '../../pages/createandmapcategory.dart';
import '../../pages/daily_colletion_class_wise_screen.dart';
import '../../pages/day_care.dart';
import '../../pages/day_care_fee_master.dart';
import '../../pages/daycare_feepayment_view_screen.dart';
import '../../pages/descriptors_master_screen.dart';
import '../../pages/discount_list_master_screen.dart';
import '../../pages/event_screen.dart';
import '../../pages/expenses_add_category.dart';
import '../../pages/fee_head_master.dart';
import '../../pages/fee_payment_details_screen.dart';
import '../../pages/fee_student_reports.dart';
import '../../pages/feedurationscreen.dart';
import '../../pages/fees_screen.dart';
import '../../pages/feesmasterview.dart';
import '../../pages/feetypemaster.dart';
import '../../pages/forgot_password_screen.dart';
import '../../pages/foundational_skills_master_screen.dart';
import '../../pages/galeryvideoview.dart';
import '../../pages/grade_master_screen.dart';
import '../../pages/home_work_screen.dart';
import '../../pages/homepage.dart';
import '../../pages/logInpage.dart';
import '../../pages/map_descriptors_master_screen.dart';
import '../../pages/map_foundational_skills_screen.dart';
import '../../pages/mapcategory.dart';
import '../../pages/master_certificates.dart';
import '../../pages/master_daily_activity.dart';
import '../../pages/master_expenses.dart';
import '../../pages/master_product_screen.dart';
import '../../pages/masterview.dart';
import '../../pages/mealactivityview.dart';
import '../../pages/note_screen.dart';
import '../../pages/notification_screen.dart';
import '../../pages/otpscreen.dart';
import '../../pages/parent_id_page.dart';
import '../../pages/pay_daycare_screen.dart';
import '../../pages/payment_master_screen.dart';
import '../../pages/product_quantity_screen.dart';
import '../../pages/profilepage.dart';
import '../../pages/registerview.dart';
import '../../pages/report_card_screen.dart';
import '../../pages/reports.dart';
import '../../pages/result_view_screen.dart';
import '../../pages/routepointscreen.dart';
import '../../pages/sectionview.dart';
import '../../pages/session_screen.dart';
import '../../pages/splashscreen.dart';
import '../../pages/staff_detail_screen.dart';
import '../../pages/staffaddview.dart';
import '../../pages/staffattendanceview.dart';
import '../../pages/stafftypeview.dart';
import '../../pages/staffview.dart';
import '../../pages/stationary_fee print.dart';
import '../../pages/stationary_fee_action_screen.dart';
import '../../pages/stationary_fee_student_screen.dart';
import '../../pages/stationary_inventory_screen.dart';
import '../../pages/student_screen.dart';
import '../../pages/student_wise_fee_screen.dart';
import '../../pages/student_wise_yearly_report_screen.dart';
import '../../pages/subject_class_assign_master.dart';
import '../../pages/subject_screen.dart';
import '../../pages/submitfee_screen.dart';
import '../../pages/subscription_features.dart';
import '../../pages/syllabus_screen.dart';
import '../../pages/tc_certificate_screendownload.dart';
import '../../pages/teacher_add_view.dart';
import '../../pages/teacher_attendance_view.dart';
import '../../pages/teacher_designation_view.dart';
import '../../pages/teacher_detail_view.dart';
import '../../pages/teacher_subject_screen.dart';
import '../../pages/term_result_screen.dart';
import '../../pages/totalstudentview.dart';
import '../../pages/transport_fee_screen.dart';
import '../../pages/user_access_screen.dart';
import '../../pages/user_details_screen.dart';
import '../../pages/view_curriculum.dart';
import '../../pages/view_expenses_screen.dart';
import '../../pages/view_staff_attendance_view.dart';
import '../../pages/view_teacher_attendance_view.dart';
import '../../pages/viewdaycareattendanceview.dart';
import '../../pages/viewtransactionview.dart';
import '../../wigets/app_drawer.dart';

class AppRoutes {
  static appRoutes() => [
    GetPage(
      name: RouteName.splash_screen,
      page: () => SplashScreen(),
      transition: Transition.rightToLeft,
      binding: SpalshScreenBindings(),
    ),

    GetPage(
      name: RouteName.login_screen,
      page: () => LoginScreen(),
      transition: Transition.rightToLeft,
      binding: LoginScreenBinding(),
    ),
    //  Added Forgot Password Route
    GetPage(
      name: RouteName.forgot_password_screen,
      page: () =>  ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: RouteName.feedailycollection,
      page: () =>  FeeDailyCollectionScreen(),
      transition: Transition.rightToLeft,
      binding: FeeDailyCollectionBinding(),
    ),


    GetPage(
      name: RouteName.mastercertificate,
      page: () =>  MasterCertificatesscreen(),
      transition: Transition.rightToLeft,
      binding: mastercertificatebinding(),
    ),

    GetPage(
      name: RouteName.dobcertificate,
      page: () =>  StudentListScreen(),
      transition: Transition.rightToLeft,
      binding: StudentListBinding(),
    ),

    GetPage(
      name: RouteName.tc,
      page: () =>  TransferCertificateReportsScreen(),
      transition: Transition.rightToLeft,
      binding: TransferCertificateReportsbinding(),
    ),

    GetPage(
      name: RouteName.tccertificatedownload,
      page: () =>  TcCertificateScreen(),
      transition: Transition.rightToLeft,
      binding: TcCertificateBinding(),
    ),

    GetPage(
      name: RouteName.subjectclassassign,
      page: () =>  SubjectClassAssignMasterScreen(),
      transition: Transition.rightToLeft,
      binding: SubjectClassAssignBinding(),
    ),

    GetPage(
      name: RouteName.discountfeelist,
      page: () =>  DiscountListMasterScreen(),
      transition: Transition.rightToLeft,
      binding: discountlistmasterbinding(),
    ),

    GetPage(
      name: RouteName.staffdetails,
      page: () =>  StaffDetailsScreen(),
      transition: Transition.rightToLeft,
      binding: StaffDetailsBinding(),
    ),


    GetPage(
      name: RouteName.dashboard_screen,
      page: () => Dhashoard(),
      transition: Transition.rightToLeft,
      binding: DashboardScreenBinding(),
    ),
    GetPage(
      name: RouteName.ClassWiseFee,
      page: () => ClassWiseFeeStructureScreen(),
      transition: Transition.rightToLeft,
      binding: ClassWiseFeeStructureBinding(),
    ),

    GetPage(
      name: RouteName.DailyCollectionHeadWise,
      page: () => DailyCollectionFeeHeadWiseScreen(),
      transition: Transition.rightToLeft,
      binding: DailyCollectionFeeHeadWiseBinding(),
    ),


    GetPage(
      name: RouteName.FeeStudentreports,
      page: () => FeeStudentReportsScreen(),
      transition: Transition.rightToLeft,
      binding: FeeStudentBinding(),
    ),

    GetPage(
      name: RouteName.FeedetailsStudentreports,
      page: () => FeeStudentReportsScreen(),
      transition: Transition.rightToLeft,
      binding: Feedetailsstudentreportbinding(),
    ),


    GetPage(
      name: RouteName.DailyCollectionclassWise,
      page: () => FeeCollectionClassWiseScreen(),
      transition: Transition.rightToLeft,
      binding: DailyCollectionClassWiseBinding(),
    ),

    GetPage(
      name: RouteName.feetypereport,
      page: () => FeeTypeReportScreen(),
      transition: Transition.rightToLeft,
      binding: FeeTypeReportBinding(),
    ),


    GetPage(
      name: RouteName.galeryvideo,
      page: () => Galeryvideoview(),
      transition: Transition.rightToLeft,
      binding: Galleryvideobinding(),
    ),
    GetPage(
      name: RouteName.profile_screen,
      page: () => ProfilePage(),
      transition: Transition.rightToLeft,
      binding: ProfileScreenBinding(),
    ),

    GetPage(
      name: RouteName.grademaster,
      page: () => GradeMasterScreen(),
      transition: Transition.rightToLeft,
      binding: gradeMasterBinding(),
    ),



      GetPage(
      name: RouteName.communicationview,
      page: () => Communicationview(),
      transition: Transition.rightToLeft,
      binding: Communicationbinding(),
    ),

    GetPage(
      name: RouteName.allFeeReportmonths,
      page: () =>  AllFeeReportScreen(),
      transition: Transition.rightToLeft,
      binding: AllFeeReportBinding(),
    ),

    GetPage(
      name: RouteName.feePaymentDetailsReports,
      page: () => FeePaymentDetailsScreen(),
      transition: Transition.rightToLeft,
      binding: FeePaymentDetailsBinding(),
    ),

    GetPage(
      name: RouteName.ViewGirlsBoysReport,
      page: () => ViewGirlsBoysReportScreen(),
      transition: Transition.rightToLeft,
      binding: ViewGirlsBoysReportBinding(),
    ),
      GetPage(
      name: RouteName.activity,
      page: () => Activityview(),
      transition: Transition.rightToLeft,
      binding: Activitybinding(),
    ),
    GetPage(
      name: RouteName.teacherdetailview,
      page: () => TeacherDetailScreen(),
      transition: Transition.rightToLeft,
      binding: TeacherDetailBinding(),
    ),

    GetPage(
      name: RouteName.masterdailyactivity,
      page: () => MasterDailyActivityScreen(),
      transition: Transition.rightToLeft,
      binding: MasterDailyActivityBinding(),
    ),

    GetPage(
      name: RouteName.student_wisefeereport,
      page: () => StudentWiseFeeScreen(),
      transition: Transition.rightToLeft,
      binding: StudentWiseFeeBinding(),
    ),

    GetPage(
      name: RouteName.attendancedetailsdaycareview,
      page: () => AttendanceDetailsDayCareView(),
      transition: Transition.rightToLeft,
      binding: AttendanceDetailsDayCareBinding(),
    ),


    GetPage(
      name: RouteName.viewcurriculumview,
      page: () => ViewCurriculumView(),
      transition: Transition.rightToLeft,
      binding: ViewCurriculumBinding(),
    ),


    GetPage(
      name: RouteName.feesmaster,
      page: () => Feesmasterview(),
      transition: Transition.rightToLeft,
      binding: Feesbindingmaster(),
    ),
    GetPage(
      name: RouteName.totalstudent,
      page: () => Totalstudentview(),
      transition: Transition.rightToLeft,
      binding: Totalstudentbinding(),
    ),
     GetPage(
      name: RouteName.activitymaster,
      page: () => Activityviewmaster(),
      transition: Transition.rightToLeft,
      binding: Activieybindingmaster(),
    ),
     GetPage(
      name: RouteName.mealactivity,
      page: () => Mealactivityview(),
      transition: Transition.rightToLeft,
      binding: Mealbinding(),
    ),

    GetPage(
      name: RouteName.staffdetailview,
      page: () => StaffDetailScreen(),
      transition: Transition.rightToLeft,
      binding: StaffDetailBinding(),
    ),

    GetPage(
      name: RouteName.changepassword,
      page: () => ChangePasswordScreen(),
      transition: Transition.rightToLeft,
      binding: ChangePasswordBinding(),
    ),

     GetPage(
      name: RouteName.behaviour,
      page: () => Behaviourview(),
      transition: Transition.rightToLeft,
      binding: Behaviourbinding(),
    ),
     GetPage(
      name: RouteName.addstudentmaster,
      page: () => Addstudentmaster(),
      transition: Transition.rightToLeft,
      binding: Addstudentbinding(),
    ),
     GetPage(
      name: RouteName.profile_screen,
      page: () => ProfilePage(),
      transition: Transition.rightToLeft,
      binding: ProfileScreenBinding(),
    ),
     GetPage(
      name: RouteName.master,
      page: () => Masterview(),
      transition: Transition.rightToLeft,
      binding: Masterbinding(),
    ),

    GetPage(
      name: RouteName.mapfoundationaldescriptioskills,
      page: () => MapFoundationalSkillsScreen(),
      transition: Transition.rightToLeft,
      binding: MapFoundationalSkillsBinding(),
    ),

    GetPage(
      name: RouteName.results,
      page: () => ResultViewScreen(),
      transition: Transition.rightToLeft,
      binding: ResultViewBinding(),
    ),

    GetPage(
      name: RouteName.products,
      page: () => ProductMasterViewScreen(),
      transition: Transition.rightToLeft,
      binding: ProductMasterViewBinding(),
    ),

    GetPage(
      name: RouteName.masterexpenses,
      page: () => Masterexpensesscreen(),
      transition: Transition.rightToLeft,
      binding: masterexpensesbinding(),
    ),

    GetPage(
      name: RouteName.userdetails,
      page: () => UserDetailsScreen(),
      transition: Transition.rightToLeft,
      binding: UserDetailsBinding(),
    ),
    GetPage(
      name: RouteName.useraccess,
      page: () => UserAccessScreen(),
      transition: Transition.rightToLeft,
      binding: UserAccessBinding(),
    ),

     GetPage(
       name: RouteName.addproducts,
       page: () => AddProductsScreen(),
       transition: Transition.rightToLeft,
       binding: AddProductsBinding(),
     ),

    GetPage(
      name: RouteName.addexpenses,
      page: () => AddExpenseScreen(),
      transition: Transition.rightToLeft,
      binding: AddexpensesBinding(),
    ),

    GetPage(
      name: RouteName.viewexpenses,
      page: () => ViewExpensesScreen(),
      transition: Transition.rightToLeft,
      binding: ViewexpensesBinding(),
    ),

    GetPage(
      name: RouteName.addcategoryexpenses,
      page: () => ExpensesCategoryScreen(),
      transition: Transition.rightToLeft,
      binding: ExpensesCategoryBinding(),
    ),

    GetPage(
      name: RouteName.stationaryfee,
      page: () => StationaryFeeStudentScreen(),
      transition: Transition.rightToLeft,
      binding: StationaryFeeStudentBinding(),
    ),

    GetPage(
      name: RouteName.stationaryinventory,
      page: () => StationaryInventoryScreen(),
      transition: Transition.rightToLeft,
      binding: StationaryInventoryBinding(),
    ),



    GetPage(
      name: RouteName.productquantity,
      page: () => ProductQuantityScreen(),
      transition: Transition.rightToLeft,
      binding: ProductQuantityBinding(),
    ),


    GetPage(
      name: RouteName.foundationalskills,
      page: () => FoundationalSkillsMasterScreen(),
      transition: Transition.rightToLeft,
      binding: FoundationalSkillsBinding(),
    ),

    GetPage(
      name: RouteName.termsresult,
      page: () => TermResultScreen (),
      transition: Transition.rightToLeft,
      binding: TermResultBinding (),
    ),

    GetPage(
      name: RouteName.Resultadd,
      page: () => AddResultMasterScreen  (),
      transition: Transition.rightToLeft,
      binding:  AddResultBinding (),
    ),

    GetPage(
      name: RouteName.ResultReportcard,
      page: () =>  ReportCardScreen (),
      transition: Transition.rightToLeft,
      binding:  ReportCardBinding (),
    ),


    GetPage(
      name: RouteName.descriptors,
      page: () => DescriptorsMasterScreen(),
      transition: Transition.rightToLeft,
      binding: DescriptorsBinding(),
    ),

    GetPage(
      name: RouteName.mapdescriptor,
      page: () => MapDescriptorsMasterScreen(),
      transition: Transition.rightToLeft,
      binding: MapDescriptorsBinding(),
    ),


    GetPage(
      name: RouteName.feetypemaster,
      page: () => FeeTypeMasterScreen(),
      transition: Transition.rightToLeft,
      binding: feetypebinding(),
    ),

    GetPage(
      name: RouteName.teachersubject,
      page: () => TeacherSubjectScreen(),
      transition: Transition.rightToLeft,
      binding: TeacherSubjectBinding(),
    ),


    GetPage(
      name: RouteName.addroutemaster,
      page: () => RouteMasterScreen(),
      transition: Transition.rightToLeft,
      binding: RouteMasterBinding(),
    ),

    GetPage(
      name: RouteName.routepointmaster,
      page: () => RoutePointMasterScreen(),
      transition: Transition.rightToLeft,
      binding: RoutePointBinding(),
    ),

    GetPage(
      name: RouteName.feeheadmaster,
      page: () => AddFeeHeadScreen(),
      transition: Transition.rightToLeft,
      binding: AddFeeHeadBinding(),
    ),

    GetPage(
      name: RouteName.addteachers,
      page: () => AddTeacherView(),
      transition: Transition.rightToLeft,
      binding: TeacherAddBinding(),
    ),
  GetPage(
      name: RouteName.addstaff,
      page: () => Staffaddview(),
      transition: Transition.rightToLeft,
      binding: Staffviewbinding(),
    ),
    GetPage(
      name: RouteName.classteacher,
      page: () => ClassTeacherScreen(),
      transition: Transition.rightToLeft,
      binding: ClassTeacherBinding(),
    ),
GetPage(
      name: RouteName.staffView,
      page: () => Staffview(),
      transition: Transition.rightToLeft,
      binding: Staffviewbinding(),
    ),

    GetPage(
      name: RouteName.teacherdesignation,
      page: () => TeacherDesignationView(),
      transition: Transition.rightToLeft,
      binding: TeacherDesignationBinding(),
    ),
    GetPage(
      name: RouteName.stafftype,
      page: () => Stafftypeview(),
      transition: Transition.rightToLeft,
      binding: Stafftypebinding(),
    ),

    GetPage(
      name: RouteName.teacherattendance,
      page: () => TeacherAttendanceView(),
      transition: Transition.rightToLeft,
      binding: TeacherAttendanceBinding(),
    ),

    GetPage(
      name: RouteName.staffattendance,
      page: () => Staffattendanceview(),
      transition: Transition.rightToLeft,
      binding: Staffattendancebinding(),
    ),
    GetPage(
      name: RouteName.viewteacherattendance,
      page: () => ViewTeacherAttendanceScreen(),
      transition: Transition.rightToLeft,
      binding: ViewTeacherAttendanceBinding(),
    ),
 GetPage(
      name: RouteName.viewstaffattendance,
      page: () => ViewStaffAttendanceScreen (),
      transition: Transition.rightToLeft,
      binding: Viewstaffattendance(),
    ),

    GetPage(
      name: RouteName.paymentmaster,
      page: () => PaymentMasterScreen(),
      transition: Transition.rightToLeft,
      binding: PaymentMasterBinding(),
    ),

    GetPage(
      name: RouteName.daycarefeemaster,
      page: () => AddDayCareFeeMasterScreen(),
      transition: Transition.rightToLeft,
      binding: DayCareFeeMasterBinding(),
    ),


    GetPage(
      name: RouteName.feedurationmaster,
      page: () => FeeDurationMasterScreen(),
      transition: Transition.rightToLeft,
      binding: FeeDurationBinding(),
    ),

     GetPage(
      name: RouteName.mapcategory,
      page: () => Mapcategoryview(),
      transition: Transition.rightToLeft,
      binding: Mapcategorybinding(),
    ),
     GetPage(
      name: RouteName.reports,
      page: () => Reportsview(),
      transition: Transition.rightToLeft,
      binding: Reportsbinding(),
    ),

    GetPage(
      name: RouteName.studentwiseyearlyreport,
      page: () => StudentWiseYearlyReportScreen(),
      transition: Transition.rightToLeft,
      binding: StudentWiseYearlyReportBinding(),
    ),

     GetPage(
      name: RouteName.teacher,
      page: () => Teacherview(),
      transition: Transition.rightToLeft,
      binding: Teacherbinding(),
    ),
    GetPage(
      name: RouteName.app_drawer,
      page: () => AppDrawer(),
      binding: AppDrawerScreenBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.session_screen,
      page: () => SessionScreen(),
      binding: SessionBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.subject_screen,
      page: () => SubjectScreen(),
      binding: SubjectBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.class_screen,
      page: () => ClassScreen(),
      binding: ClassBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.student_screen,
      page: () => StudentScreen(),
      binding: StudentBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.event_screen,
      page: () => EventScreen(),
      binding: EventBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.note_screen,
      page: () => NoteScreen(),
      binding: NoteBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.notification_screen,
      page: () => NotificationScreen(),
      binding: NotificationBinding(),
      transition: Transition.leftToRight,
    ),


    GetPage(
      name: RouteName.DailyActivity,
      page: () => DailyActivityScreen(),
      binding: DailyActivityBinding(),
      transition: Transition.leftToRight,
    ),

    GetPage(
      name: RouteName.fees_screen,
      page: () => FeesScreen(),
      binding: FeesBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.submit_fee,
      page: () => SubmitFeeScreen(),
      binding: SubmitFeeBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.add_discount,
      page: () => AddDiscountScreen(),
      binding: DiscountBinding(),
      transition: Transition.leftToRight,
    ),
     GetPage(
      name: RouteName.registerview,
      page: () => RegisterView(),
      binding: Registerbinding(),
      transition: Transition.leftToRight,
    ),
     GetPage(
      name: RouteName.otp,
      page: () => OTPLoginScreen(),
      binding: Registerbinding(),
      transition: Transition.leftToRight,
    ),
     
    GetPage(
      name: RouteName.day_care,
      page: () => DayCare(),
      binding: DayCareBinding(),
      transition: Transition.leftToRight,
    ),

    GetPage(
      name: RouteName.daycarefeepaymentview,
      page: () => DaycareFeePaymentScreen(),
      binding: DaycareFeePaymentBinding(),
      transition: Transition.leftToRight,
    ),

    GetPage(name: RouteName.subscriptionplans, page: () =>  SubscriptionPlansScreen()),

     GetPage(
      name: RouteName.section,
      page: () => sectionview(),
      binding: Sectionbinding(),
      transition: Transition.leftToRight,
    ),
     GetPage(
      name: RouteName.createandmapcategory,
      page: () => Createandmapcategoryview(),
      binding: Createandmapcategorybinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.pay_day_care,
      page: () => PayDayCScreen(),
      binding: PayDayCBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.attendance_screen,
      page: () => AttendancePage(),
      binding: AttendanceBinding(),
    ),

    GetPage(
      name: RouteName.parentsidscreens,
      page: () => ParentIdPage(),
      binding: ParentIdBinding(),
    ),
      GetPage(
        name: RouteName.view_attendance_screen,
        page: () => ViewAttendancePage(),
        binding: ViewAttendanceBinding(),
      ),
      //view transaction
       GetPage(
        name: RouteName.viewtransaction,
        page: () => Viewtransactionview(),
        binding: Viewtransctionbinding(),
      ),
       GetPage(
        name: RouteName.daycaretakeattendanceview,
        page: () => Daycaretakeattendanceview(),
        binding: Daycareattendancebinding(),
      ),
      GetPage(
        name: RouteName.viewdaycareattendance,
        page: () => Viewdaycareattendanceview(),
        binding: Viewdaycarebinding(),
      ),

    GetPage(
      name: RouteName.stationaryfeeaction,
      page: () => StationaryFeeActionScreen(),
      binding: StationaryFeeActionBinding(),
    ),

        GetPage(
        name: RouteName.adddaycarestudent,
        page: () => StudentScreen2(),
        binding: StudentScreen2Bindings(),
      ),
    GetPage(
      name: RouteName.homework,
      page: () => HomeworkScreen(),
      binding: HomeworkBinding(),
    ),

    GetPage(
      name: RouteName.stationaryfeePrint,
      page: () =>  StationaryFeePrintScreen(),
      binding: StationaryFeePrintBinding(),
    ),

  GetPage(
   name: RouteName.transportFee,
   page: () =>  TransportFeeScreen(),
   binding: TransportFeeBinding(),
 ),

    GetPage(
      name: RouteName.syllabus,
      page: () => SyllabusScreen(),
      binding: SyllabusBinding(),
    ),
  ];
}
