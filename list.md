
好的 ✅
我来帮你整理一份 **调用示例清单**，对应你项目里各个文件中原本的 API 调用函数，并给出如何替换为 `LocalApiService`。

---

## 🔹 调用替换清单

### 1. `lib/Global/local_api_service.dart`

原来这里有很多 `get_xxx`、`post_xxx`，现在已经迁移到新的 `LocalApiService`，其他地方不需要直接调用旧的 API 了。
👉 **删除旧文件内容**，保留我给你的新版本。

---

### 2. `lib/screens/audiometry/*.dart`

涉及函数：`getSource`、`SaveResult`、`play`

* **原来**：

```dart
final source = await getSource("mode1");
await SaveResult(record);
```

* **替换**：

```dart
final source = await LocalApiService().getSource("mode1");
await LocalApiService().saveResult(record);
```

---

### 3. `lib/screens/calibration/calibration_screen.dart`

涉及函数：`SaveResult`

* **原来**：

```dart
await SaveResult(record);
```

* **替换**：

```dart
await LocalApiService().saveResult(record);
```

---

### 4. `lib/screens/calibration/noisemeter.dart`

涉及函数：`checkIsCalibration`

* **原来**：

```dart
final ok = await checkIsCalibration(device);
```

* **替换**：

```dart
final ok = await LocalApiService().checkIsCalibration(device);
```

---

### 5. `lib/screens/home/home_screen.dart`

涉及函数：`getDeviceInfo`、`checkIsCalibration`、`openBluetooth`、`_getSubjects`

* **原来**：

```dart
final info = await getDeviceInfo();
final ok = await checkIsCalibration(device);
await openBluetooth();
final subjects = await _getSubjects();
```

* **替换**：

```dart
final info = await LocalApiService().getDeviceInfo();
final ok = await LocalApiService().checkIsCalibration(device);
await LocalApiService().openBluetooth();
final subjects = await LocalApiService().getSubjects();
```

---

### 6. `lib/screens/sgin_in/components/sign_form.dart`

涉及函数：`_gainUsers`（实际是获取用户信息）

* **原来**：

```dart
final users = await _gainUsers();
```

* **替换**：

```dart
final users = await LocalApiService().getSubjects();
```

---

### 7. `lib/screens/subject/components/subject_form.dart`

涉及函数：`_getSubjectInfo`

* **原来**：

```dart
final subject = await _getSubjectInfo(subjectId);
```

* **替换**：

```dart
final subject = await LocalApiService().getSubject(subjectId);
```

---

### 8. `lib/screens/subject_management/subject_record.dart`

涉及函数：`_getTestRecord`

* **原来**：

```dart
final records = await _getTestRecord(subjectId);
```

* **替换**：

```dart
final records = await LocalApiService().getSubjectTestRecords(subjectId);
```

---

### 9. `lib/screens/subject_management/components/subject_record_detail.dart`

涉及函数：`_getResource`

* **原来**：

```dart
final res = await _getResource("mode1");
```

* **替换**：

```dart
final res = await LocalApiService().getResource("mode1");
```

---

### 10. `lib/screens/subject_management/components/subjectmana_form.dart`

涉及函数：`_getSubjects`

* **原来**：

```dart
final subjects = await _getSubjects();
```

* **替换**：

```dart
final subjects = await LocalApiService().getSubjects();
```

---

### 11. `lib/screens/subject_management/components/subjects_list.dart`

涉及函数：`getDeviceInfo`、`checkIsCalibration`

* **原来**：

```dart
final info = await getDeviceInfo();
final ok = await checkIsCalibration(device);
```

* **替换**：

```dart
final info = await LocalApiService().getDeviceInfo();
final ok = await LocalApiService().checkIsCalibration(device);
```

---

## 🔹 总结

所有 API 调用都要遵循以下规则：

* **原来**：`get_xxx()` / `post_xxx()` / `_getXxx()` / `SaveResult()`
* **现在**：`LocalApiService().xxx()`

---

要不要我帮你直接输出一份 **表格形式的对照清单（函数名 → 替换后调用方式 → 所在文件）**，方便你批量替换？
