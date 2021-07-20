import 'package:flutter/material.dart';

class CheckValidate {
  String? email(String value, {FocusNode? focusNode}) {
    if (value.isEmpty) {
      // focusNode.requestFocus();
      return '이메일을 입력하세요.';
    } else {
      String pattern =
          r'^(([^<>()[\]\\,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        // focusNode.requestFocus();
        return '잘못된 이메일 형식입니다.';
      } else {
        return null;
      }
    }
  }

  String? password(String value, {FocusNode? focusNode}) {
    if (value.isEmpty) {
      // focusNode.requestFocus();
      return '비밀번호를 입력하세요.';
    } else {
      String pattern =
          // r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,15}$';
          r'^(?=.*[A-Za-z])[A-Za-z\d]{8,15}$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        // focusNode.requestFocus();
        return '대소문자, 숫자 포함 8자 이상 15자 이내로 입력하세요.';
      } else {
        return null;
      }
    }
  }

  String? loginPassword(String value, {FocusNode? focusNode}) {
    if (value.isEmpty) {
      return '비밀번호를 입력하세요.';
    } else {
      return null;
    }
  }

  String? passwordAgain(String value, String password, {FocusNode? focusNode}) {
    if (value == password) {
      return null;
    } else {
      // focusNode.requestFocus();
      return '비밀번호가 일치하지 않습니다.';
    }
  }

  String? emailConfirm(String value, String confirm, {FocusNode? focusNode}) {
    if (value == confirm) {
      return null;
    } else {
      // focusNode.requestFocus();
      return '인증번호가 일치하지 않습니다.';
    }
  }

  String? name(String value) {
    if (value.isEmpty) {
      return '이름을 입력해주세요';
    } else {
      String pattern = r'^[가-힣|a-z|A-Z|]+$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value) || value.length < 2) {
        return '이름을 정확히 입력해주세요';
      } else {
        return null;
      }
    }
  }

  String? nickName(String value) {
    if (value.isEmpty) {
      return '닉네임을 입력해주세요';
    } else {
      String pattern = r'^[가-힣|a-z|A-Z|0-9]+$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        return '특수문자는 사용 불가합니다';
      } else {
        return null;
      }
    }
  }

  String? gender(String value) {
    if (value.isEmpty) {
      return '성별을 선택해주세요';
    } else {
      return null;
    }
  }

  String? phoneNumber(String value) {
    if (value.isEmpty) {
      return '전화번호를 입력해주세요';
    } else {
      String pattern = r'^[0-9|-]+$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        return '숫자만 입력 가능합니다';
      } else {
        return null;
      }
    }
  }
}
