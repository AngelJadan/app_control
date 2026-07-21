import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../data/models/venta_model.dart';

class InvoiceService {
  static Future<void> generateAndPrintFullReport(
    List<VentaModel> ventas,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateOnlyFormat = DateFormat('dd/MM/yyyy');

    double totalIngresos = 0;
    double totalEfectivo = 0;
    double totalTransferencia = 0;
    double totalDeposito = 0;
    double totalCortesia = 0;
    double totalEnFactura = 0;

    double cantidadProductosEfectivo = 0;
    double cantidadProductosTransferencia = 0;
    double cantidadProductosDeposito = 0;
    double cantidadProductosCortesia = 0;
    double cantidadProductosEnFactura = 0;

    int totalProductos = 0;

    for (var venta in ventas) {
      if (venta.formaPago == 'Efectivo') {
        totalEfectivo += venta.total;
        for (var producto in venta.productos) {
          cantidadProductosEfectivo += producto.cantidad;
        }
      }
      if (venta.formaPago == 'Transferencia') {
        totalTransferencia += venta.total;
        for (var producto in venta.productos) {
          cantidadProductosTransferencia += producto.cantidad;
        }
      }
      if (venta.formaPago == 'Depósito') {
        totalDeposito += venta.total;
        for (var producto in venta.productos) {
          cantidadProductosDeposito += producto.cantidad;
        }
      }
      if (venta.formaPago == 'Cortesía') {
        totalCortesia += venta.total;
        for (var producto in venta.productos) {
          cantidadProductosCortesia += producto.cantidad;
        }
      }
      if (venta.formaPago == 'En factura') {
        totalEnFactura += venta.total;
        for (var producto in venta.productos) {
          cantidadProductosEnFactura += producto.cantidad;
        }
      }
      for (var producto in venta.productos) {
        totalProductos += producto.cantidad;
      }
      totalIngresos += venta.total;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Encabezado del reporte
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'REPORTE DE VENTAS',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Control de Inventario y Ventas',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Período: ${dateOnlyFormat.format(fechaInicio)} - ${dateOnlyFormat.format(fechaFin)}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Fecha de Generación: ${dateOnlyFormat.format(DateTime.now())}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Total Ventas: ${ventas.length}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Productos Vendidos: $totalProductos',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 16),

            // Tabla resumen
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RESUMEN',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.blue100,
                        ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Total de Ventas',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Total Ingresos (Sin forma de pago en Cortesía y Factura)',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Productos Vendidos',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${ventas.length}',
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '\$${totalIngresos.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green800,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '$totalProductos',
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      totalEfectivo > 0
                          ? pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'En efectivo',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '\$${totalEfectivo.toStringAsFixed(2)}',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green800,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '$cantidadProductosEfectivo',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          )
                          : pw.TableRow(children: []),
                      totalTransferencia > 0
                          ? pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'En transferencia',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '\$${totalTransferencia.toStringAsFixed(2)}',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green800,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '$cantidadProductosTransferencia',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          )
                          : pw.TableRow(children: []),
                      totalDeposito > 0
                          ? pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'En depósito',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '\$${totalDeposito.toStringAsFixed(2)}',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green800,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '$cantidadProductosDeposito',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          )
                          : pw.TableRow(children: []),
                      totalCortesia > 0
                          ? pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Cortesía',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '\$${totalCortesia.toStringAsFixed(2)}',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green800,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '$cantidadProductosCortesia',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          )
                          : pw.TableRow(children: []),
                      totalEnFactura > 0
                          ? pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'En factura',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '\$${totalEnFactura.toStringAsFixed(2)}',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green800,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '$cantidadProductosEnFactura',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          )
                          : pw.TableRow(children: []),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 16),

            // Detalle de ventas
            pw.Text(
              'DETALLE DE VENTAS',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...ventas.map((venta) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Documento #${venta.id} - ${venta.nombreCliente}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          dateFormat.format(venta.fecha),
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Pago: ${venta.formaPago}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Subtotal: \$${venta.subtotal.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                        pw.Text(
                          'Descuento: \$${venta.descuento.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                        pw.Text(
                          'Total: \$${venta.total.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                      ],
                    ),
                    if (venta.observacion != null &&
                        venta.observacion!.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 6),
                        child: pw.Text(
                          'Obs: ${venta.observacion}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ),
                    pw.SizedBox(height: 8),
                    // Productos de esta venta
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(color: PdfColors.grey300),
                        ),
                      ),
                      padding: const pw.EdgeInsets.only(top: 8),
                      child: pw.Table(
                        border: pw.TableBorder(
                          horizontalInside: pw.BorderSide(
                            color: PdfColors.grey200,
                          ),
                        ),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(2),
                          1: const pw.FlexColumnWidth(0.8),
                          2: const pw.FlexColumnWidth(0.8),
                          3: const pw.FlexColumnWidth(0.8),
                        },
                        children: [
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.grey100,
                            ),
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  'Producto',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  'Cant.',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  'Precio',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  'Total',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          ...venta.productos.map((producto) {
                            final subtotal =
                                producto.cantidad * producto.precioUnitario;
                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    producto.nombreProducto ?? 'Producto',
                                    style: const pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    '${producto.cantidad}',
                                    style: const pw.TextStyle(fontSize: 9),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    '\$${producto.precioUnitario.toStringAsFixed(2)}',
                                    style: const pw.TextStyle(fontSize: 9),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    '\$${subtotal.toStringAsFixed(2)}',
                                    style: const pw.TextStyle(fontSize: 9),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateAndPrintInvoice(VentaModel venta) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    double totalProductos = 0;
    for (var producto in venta.productos) {
      totalProductos += producto.cantidad * producto.precioUnitario;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'FACTURA #${venta.id}',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Control de Inventario y Ventas',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Fecha: ${dateFormat.format(venta.fecha)}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Forma de Pago: ${venta.formaPago}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 12),

                // Información del cliente
                pw.Text(
                  'CLIENTE',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  venta.nombreCliente,
                  style: const pw.TextStyle(fontSize: 11),
                ),
                if (venta.observacion != null && venta.observacion!.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Text(
                      'Observación: ${venta.observacion}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                pw.SizedBox(height: 20),

                // Tabla de productos
                pw.Text(
                  'PRODUCTOS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Encabezado de tabla
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Producto',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Cantidad',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Precio Unit.',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Total',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Filas de productos
                    ...venta.productos.map((producto) {
                      final subtotal =
                          producto.cantidad * producto.precioUnitario;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              producto.nombreProducto ?? 'Producto',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              producto.cantidad.toString(),
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '\$${producto.precioUnitario.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '\$${subtotal.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 12),

                // Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              'Subtotal: ',
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                            pw.Text(
                              '\$${totalProductos.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text(
                                'TOTAL: ',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                '\$${venta.total.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Gracias por su compra',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
