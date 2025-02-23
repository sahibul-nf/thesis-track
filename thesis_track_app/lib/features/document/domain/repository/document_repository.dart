import 'dart:io';

abstract class DocumentRepository {
  Future<String> uploadDraftDocument(String thesisId, File document);
  Future<String> uploadFinalDocument(String thesisId, File document);
}