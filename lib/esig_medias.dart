library esig_medias;

import 'dart:convert';
import 'dart:io';

import 'package:esig_utils/status.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_empty_error/snackbar.dart';
import 'package:one_context/one_context.dart';
import 'package:permission_handler/permission_handler.dart';

class EsigMedias {
  Future<void> anexarGaleriaFilePicker(
      Status status, File? imagemSelecionada, dynamic tratamentoErro) async {
    status = Status.AGUARDANDO;
    final statusRequest = await Permission.storage.request();
    if (statusRequest.isDenied || statusRequest.isPermanentlyDenied) {
      status = Status.ERRO;
    } else {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null) {
          imagemSelecionada = File(result.files.single.path ?? '');
          status = await converteParaBase64(imagemSelecionada.path);
          status = verificaTamanhoArquivo(imagemSelecionada);
          //Modular.to.pop();
        } else {
          status = Status.VAZIO;
        }
      } on PlatformException {
        status = Status.ERRO;
        getEsigSnackBar(
          'Erro ao abrir a camera tente novamente',
          context: OneContext().context,
          corFundo: Colors.red,
        );
      } catch (e) {
        status = Status.ERRO;
        tratamentoErro;
      }
    }
  }

  converteParaBase64(String? imagePath) async {
    try {
      File imagefile = File(imagePath!);
      Uint8List imagebytes = await imagefile.readAsBytes();
      base64.encode(imagebytes);
      return Status.CONCLUIDO;
    } catch (e) {
      getEsigSnackBar(
        'Não foi possivel anexar esse tipo de arquivo',
        context: OneContext().context,
        corFundo: Colors.red,
      );
      return Status.NAO_CARREGADO;
    }
  }

  Status verificaTamanhoArquivo(File? file) {
    int sizeInBytes = file!.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb >= 8) {
      file = null;
      getEsigSnackBar(
        'Tamanho do arquivo muito grande, limite de 8MB',
        context: OneContext().context,
        corFundo: Colors.red,
        duracao: 10,
      );
      return Status.NAO_CARREGADO;
    } else {
      return Status.CONCLUIDO;
    }
  }
}
