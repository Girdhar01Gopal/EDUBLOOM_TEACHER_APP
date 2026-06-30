class DiscountData {
    int id;
    String session;
    dynamic discountDatumClass;
    dynamic section;
    String feeType;
    dynamic feesDuration;
    int discount;
    String action;
    dynamic statues;
    dynamic studentid;
    String description1;
    dynamic fileName1;
    String schoolId;
    dynamic registrationNo;
    dynamic studentName;
    dynamic fatherName;
    dynamic admissionNo;
    dynamic createddBy;

    DiscountData({
        required this.id,
        required this.session,
        required this.discountDatumClass,
        required this.section,
        required this.feeType,
        required this.feesDuration,
        required this.discount,
        required this.action,
        required this.statues,
        required this.studentid,
        required this.description1,
        required this.fileName1,
        required this.schoolId,
        required this.registrationNo,
        required this.studentName,
        required this.fatherName,
        required this.admissionNo,
        required this.createddBy,
    });

    DiscountData copyWith({
        int? id,
        String? session,
        dynamic discountDatumClass,
        dynamic section,
        String? feeType,
        dynamic feesDuration,
        int? discount,
        String? action,
        dynamic statues,
        dynamic studentid,
        String? description1,
        dynamic fileName1,
        String? schoolId,
        dynamic registrationNo,
        dynamic studentName,
        dynamic fatherName,
        dynamic admissionNo,
        dynamic createddBy,
    }) => 
        DiscountData(
            id: id ?? this.id,
            session: session ?? this.session,
            discountDatumClass: discountDatumClass ?? this.discountDatumClass,
            section: section ?? this.section,
            feeType: feeType ?? this.feeType,
            feesDuration: feesDuration ?? this.feesDuration,
            discount: discount ?? this.discount,
            action: action ?? this.action,
            statues: statues ?? this.statues,
            studentid: studentid ?? this.studentid,
            description1: description1 ?? this.description1,
            fileName1: fileName1 ?? this.fileName1,
            schoolId: schoolId ?? this.schoolId,
            registrationNo: registrationNo ?? this.registrationNo,
            studentName: studentName ?? this.studentName,
            fatherName: fatherName ?? this.fatherName,
            admissionNo: admissionNo ?? this.admissionNo,
            createddBy: createddBy ?? this.createddBy,
        );
}
