import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/venta/venta_bloc.dart';
import '../../blocs/venta/venta_event.dart';
import '../../blocs/venta/venta_state.dart';
import '../../data/models/venta_model.dart';
import '../../services/invoice_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  late DateTime _fechaInicio;
  late DateTime _fechaFin;
  final Set<int> _expandedRows = {};

  @override
  void initState() {
    super.initState();
    _fechaInicio = DateTime.now();
    _fechaFin = DateTime.now();
    _cargarReporte();
  }

  void _cargarReporte() {
    context.read<VentaBloc>().add(CargarReporteEvent(_fechaInicio, _fechaFin));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reportes de Ventas por Fecha',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildFilterSection(context),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<VentaBloc, VentaState>(
              builder: (context, state) {
                if (state is VentaLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReporteCargadoState) {
                  if (state.ventas.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay ventas en el rango de fechas seleccionado',
                      ),
                    );
                  }
                  return _buildReportTable(context, state.ventas);
                } else if (state is VentaErrorState) {
                  return Center(child: Text('Error: ${state.error}'));
                } else {
                  return const Center(child: Text('Cargando reportes...'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha Inicio:'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _seleccionarFechaInicio(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(DateFormat('dd/MM/yyyy').format(_fechaInicio)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha Fin:'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _seleccionarFechaFin(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(DateFormat('dd/MM/yyyy').format(_fechaFin)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _cargarReporte,
              icon: const Icon(Icons.refresh),
              label: const Text('Buscar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            BlocBuilder<VentaBloc, VentaState>(
              builder: (context, state) {
                if (state is ReporteCargadoState && state.ventas.isNotEmpty) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      await InvoiceService.generateAndPrintFullReport(
                        state.ventas,
                        _fechaInicio,
                        _fechaFin,
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimir Reporte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTable(BuildContext context, List<VentaModel> ventas) {
    double totalIngresos = 0;
    int totalVentas = ventas.length;
    int totalProductos = 0;

    for (var venta in ventas) {
      totalIngresos += venta.total;
      totalProductos += venta.productos.fold(
        0,
        (sum, item) => sum + item.cantidad,
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Resumen
          _buildResumenCard(totalVentas, totalIngresos, totalProductos),
          const SizedBox(height: 16),
          // Tabla de ventas expandible
          Card(
            elevation: 2,
            child: Column(
              children: [
                // Encabezado
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          'ID',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Fecha',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Cliente',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Pago',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Total',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Acciones',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Filas de ventas
                ...ventas.asMap().entries.map((entry) {
                  int index = entry.key;
                  VentaModel venta = entry.value;
                  bool isExpanded = _expandedRows.contains(index);

                  return Column(
                    children: [
                      // Fila principal
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedRows.remove(index);
                            } else {
                              _expandedRows.add(index);
                            }
                          });
                        },
                        child: Container(
                          color:
                              isExpanded
                                  ? Colors.blue.withValues(alpha: 0.1)
                                  : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text(venta.id.toString()),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(venta.fecha),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  venta.nombreCliente,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  venta.formaPago,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '\$${venta.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (isExpanded) {
                                            _expandedRows.remove(index);
                                          } else {
                                            _expandedRows.add(index);
                                          }
                                        });
                                      },
                                      tooltip: 'Expandir',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.print,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        await InvoiceService.generateAndPrintInvoice(
                                          venta,
                                        );
                                      },
                                      tooltip: 'Imprimir',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Fila expandida con detalles
                      if (isExpanded)
                        Container(
                          color: Colors.grey[50],
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (venta.observacion != null &&
                                  venta.observacion!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Observación: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: venta.observacion,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Text(
                                'Productos:',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 16,
                                  headingRowHeight: 36,
                                  dataRowMinHeight: 40,
                                  dataRowMaxHeight: 40,
                                  columns: const [
                                    DataColumn(label: Text('Producto')),
                                    DataColumn(label: Text('Cant.')),
                                    DataColumn(label: Text('Precio Unit.')),
                                    DataColumn(label: Text('Total')),
                                  ],
                                  rows:
                                      venta.productos.map((producto) {
                                        final subtotal =
                                            producto.cantidad *
                                            producto.precioUnitario;
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                producto.nombreProducto ??
                                                    'Producto',
                                              ),
                                            ),
                                            DataCell(
                                              Text('${producto.cantidad}'),
                                            ),
                                            DataCell(
                                              Text(
                                                '\$${producto.precioUnitario.toStringAsFixed(2)}',
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '\$${subtotal.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (index < ventas.length - 1) const Divider(height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard(
    int totalVentas,
    double totalIngresos,
    int totalProductos,
  ) {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildResumenItem('Total Ventas', totalVentas.toString()),
            _buildResumenItem(
              'Ingresos Totales',
              '\$${totalIngresos.toStringAsFixed(2)}',
            ),
            _buildResumenItem('Productos Vendidos', totalProductos.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  void _seleccionarFechaInicio(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        _fechaInicio = fecha;
      });
    }
  }

  void _seleccionarFechaFin(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        _fechaFin = fecha;
      });
    }
  }
}
