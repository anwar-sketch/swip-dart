import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'on_device_model.dart';

class ONNXRuntimeModel implements OnDeviceModel {
  late final OrtSession _session;
  late final ModelInfo _info;
  late final Map<String, dynamic> _metadata;
  bool _isLoaded = false;

  ONNXRuntimeModel._();

  static Future<ONNXRuntimeModel> load(String modelPath) async {
    final model = ONNXRuntimeModel._();
    await model._loadModel(modelPath);
    return model;
  }

  Future<void> _loadModel(String modelPath) async {
    try {
      // Load metadata from meta.json file
      final metaPath = modelPath.replaceAll('.onnx', '.meta.json');
      final jsonString = await rootBundle.loadString(metaPath);
      _metadata = json.decode(jsonString) as Map<String, dynamic>;

      // Initialize ONNX Runtime
      final ort = OnnxRuntime();
      _session = await ort.createSessionFromAsset(modelPath);

      // Create model info from metadata
      _info = ModelInfo(
        id: _metadata['model_id'] as String,
        type: _metadata['format'] as String? ?? 'onnx',
        checksum: (_metadata['checksum']?['value'] ?? '') as String,
        inputSchema:
            List<String>.from(_metadata['schema']['input_names'] as List),
        classNames:
            List<String>.from(_metadata['output']['class_names'] as List),
        positiveClass: _metadata['output']['positive_class'] as String?,
      );

      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load ONNX model: $e');
    }
  }

  @override
  ModelInfo get info {
    if (!_isLoaded) throw Exception('Model not loaded');
    return _info;
  }

  @override
  Future<double> predict(List<double> features) async {
    if (!_isLoaded) throw Exception('Model not loaded');

    try {
      // Prepare input tensor
      final inputName = _info.inputSchema.first; // Assuming single input
      final inputShape = [1, features.length]; // Batch size 1
      final inputTensor = await OrtValue.fromList(features, inputShape);

      // Run inference (this returns a Future)
      final inputs = {inputName: inputTensor};
      final outputs = await _session.run(inputs);

      if (outputs.isEmpty) {
        throw Exception('ONNX inference returned no outputs');
      }

      final probabilities = await _extractProbabilities(outputs);

      if (probabilities.isEmpty) {
        throw Exception('ONNX inference produced empty probabilities');
      }

      // Find the probability for the positive class (e.g. Stress)
      final positiveClassIndex = _info.classNames?.indexOf(
            _info.positiveClass ?? 'Stress',
          ) ??
          -1;
      if (positiveClassIndex >= 0 &&
          positiveClassIndex < probabilities.length) {
        return probabilities[positiveClassIndex];
      }

      // Fallback: return max probability
      return probabilities.reduce((a, b) => a > b ? a : b);
    } catch (e) {
      throw Exception('ONNX inference failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    if (_isLoaded) {
      // ONNX sessions are automatically disposed when they go out of scope
      _isLoaded = false;
    }
  }

  Future<List<double>> _extractProbabilities(
    Map<String, OrtValue> outputs,
  ) async {
    for (final entry in outputs.entries) {
      final data = await entry.value.asList();
      final flattened = _flattenToDoubles(data);
      if (flattened != null && flattened.isNotEmpty) {
        return flattened;
      }
    }
    throw Exception('Could not extract probability tensor from outputs');
  }

  List<double>? _flattenToDoubles(dynamic data) {
    if (data is List) {
      if (data.isEmpty) {
        return <double>[];
      }
      if (data.first is List) {
        return _flattenToDoubles(data.first);
      }
      if (data.first is num) {
        return data.map((e) => (e as num).toDouble()).toList();
      }
    }
    return null;
  }
}

