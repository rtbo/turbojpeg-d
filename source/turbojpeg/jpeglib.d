module turbojpeg.jpeglib;

import core.stdc.config : c_long, c_ulong;
import core.stdc.stdio : FILE;

import turbojpeg.jconfig;
import turbojpeg.jmorecfg;

extern (C) nothrow @nogc:

enum DCTSIZE = 8;
enum DCTSIZE2 = 64;
enum NUM_QUANT_TBLS = 4;
enum NUM_HUFF_TBLS = 4;
enum NUM_ARITH_TBLS = 16;
enum MAX_COMPS_IN_SCAN = 4;
enum MAX_SAMP_FACTOR = 4;

enum C_MAX_BLOCKS_IN_MCU = 10;
enum D_MAX_BLOCKS_IN_MCU = 10;

alias JSAMPROW = JSAMPLE*;
alias JSAMPARRAY = JSAMPROW*;
alias JSAMPIMAGE = JSAMPARRAY*;

alias JBLOCK = JCOEF[DCTSIZE2];
alias JBLOCKROW = JBLOCK*;
alias JBLOCKARRAY = JBLOCKROW*;
alias JBLOCKIMAGE = JBLOCKARRAY*;

alias JCOEFPTR = JCOEF*;

struct JQUANT_TBL
{
    UINT16[DCTSIZE2] quantval;
    boolean sent_table;
}

struct JHUFF_TBL
{
    UINT8[17] bits;
    UINT8[256] huffval;
    boolean sent_table;
}

struct jpeg_component_info
{
    int component_id;
    int component_index;
    int h_samp_factor;
    int v_samp_factor;
    int quant_tbl_no;
    int dc_tbl_no;
    int ac_tbl_no;

    JDIMENSION width_in_blocks;
    JDIMENSION height_in_blocks;

    static if (JPEG_LIB_VERSION >= 70)
    {
        int DCT_h_scaled_size;
        int DCT_v_scaled_size;
    }
    else
    {
        int DCT_scaled_size;
    }
    JDIMENSION downsampled_width;
    JDIMENSION downsampled_height;
    boolean component_needed;

    int MCU_width;
    int MCU_height;
    int MCU_blocks;
    int MCU_sample_width;
    int last_col_width;
    int last_row_height;

    JQUANT_TBL* quant_table;

    void* dct_table;
}

struct jpeg_scan_info
{
    int comps_in_scan;
    int[MAX_COMPS_IN_SCAN] component_index;
    int Ss, Se;
    int Ah, Al;
}

alias jpeg_saved_marker_ptr = jpeg_marker_struct*;

struct jpeg_marker_struct
{
    jpeg_saved_marker_ptr next;
    UINT8 marker;
    uint original_length;
    uint data_length;
    JOCTET* data;
}

enum JCS_EXTENSIONS = 1;
enum JCS_ALPHA_EXTENSIONS = 1;

enum J_COLOR_SPACE
{
    JCS_UNKNOWN,
    JCS_GRAYSCALE,
    JCS_RGB,
    JCS_YCbCr,
    JCS_CMYK,
    JCS_YCCK,
    JCS_EXT_RGB,
    JCS_EXT_RGBX,
    JCS_EXT_BGR,
    JCS_EXT_BGRX,
    JCS_EXT_XBGR,
    JCS_EXT_XRGB,
    JCS_EXT_RGBA,
    JCS_EXT_BGRA,
    JCS_EXT_ABGR,
    JCS_EXT_ARGB,
    JCS_RGB565
}

enum JCS_UNKNOWN = J_COLOR_SPACE.JCS_UNKNOWN;
enum JCS_GRAYSCALE = J_COLOR_SPACE.JCS_GRAYSCALE;
enum JCS_RGB = J_COLOR_SPACE.JCS_RGB;
enum JCS_YCbCr = J_COLOR_SPACE.JCS_YCbCr;
enum JCS_CMYK = J_COLOR_SPACE.JCS_CMYK;
enum JCS_YCCK = J_COLOR_SPACE.JCS_YCCK;
enum JCS_EXT_RGB = J_COLOR_SPACE.JCS_EXT_RGB;
enum JCS_EXT_RGBX = J_COLOR_SPACE.JCS_EXT_RGBX;
enum JCS_EXT_BGR = J_COLOR_SPACE.JCS_EXT_BGR;
enum JCS_EXT_BGRX = J_COLOR_SPACE.JCS_EXT_BGRX;
enum JCS_EXT_XBGR = J_COLOR_SPACE.JCS_EXT_XBGR;
enum JCS_EXT_XRGB = J_COLOR_SPACE.JCS_EXT_XRGB;
enum JCS_EXT_RGBA = J_COLOR_SPACE.JCS_EXT_RGBA;
enum JCS_EXT_BGRA = J_COLOR_SPACE.JCS_EXT_BGRA;
enum JCS_EXT_ABGR = J_COLOR_SPACE.JCS_EXT_ABGR;
enum JCS_EXT_ARGB = J_COLOR_SPACE.JCS_EXT_ARGB;
enum JCS_RGB565 = J_COLOR_SPACE.JCS_RGB565;

enum J_DCT_METHOD
{
    JDCT_ISLOW,
    JDCT_IFAST,
    JDCT_FLOAT
}

enum JDCT_ISLOW = J_DCT_METHOD.JDCT_ISLOW;
enum JDCT_IFAST = J_DCT_METHOD.JDCT_IFAST;
enum JDCT_FLOAT = J_DCT_METHOD.JDCT_FLOAT;

enum JDCT_DEFAULT = JDCT_ISLOW;
enum JDCT_FASTEST = JDCT_IFAST;

enum J_DITHER_MODE
{
    JDITHER_NONE,
    JDITHER_ORDERED,
    JDITHER_FS
}

enum JDITHER_NONE = J_DITHER_MODE.JDITHER_NONE;
enum JDITHER_ORDERED = J_DITHER_MODE.JDITHER_ORDERED;
enum JDITHER_FS = J_DITHER_MODE.JDITHER_FS;

private {
    struct jvirt_sarray_control;
    struct jvirt_barray_control;
    struct jpeg_comp_master;
    struct jpeg_c_main_controller;
    struct jpeg_c_prep_controller;
    struct jpeg_c_coef_controller;
    struct jpeg_marker_writer;
    struct jpeg_color_converter;
    struct jpeg_downsampler;
    struct jpeg_forward_dct;
    struct jpeg_entropy_encoder;
    struct jpeg_decomp_master;
    struct jpeg_d_main_controller;
    struct jpeg_d_coef_controller;
    struct jpeg_d_post_controller;
    struct jpeg_input_controller;
    struct jpeg_marker_reader;
    struct jpeg_entropy_decoder;
    struct jpeg_inverse_dct;
    struct jpeg_upsampler;
    struct jpeg_color_deconverter;
    struct jpeg_color_quantizer;
}

private mixin template jpeg_common_fields()
{
    jpeg_error_mgr* err;
    jpeg_memory_mgr* mem;
    jpeg_progress_mgr* progress;
    void* client_data;
    boolean is_decompressor;
    int global_state;
}

struct jpeg_common_struct
{
    mixin jpeg_common_fields!();
}

alias j_common_ptr = jpeg_common_struct*;
alias j_compress_ptr = jpeg_compress_struct*;
alias j_decompress_ptr = jpeg_decompress_struct*;

struct jpeg_compress_struct
{
    mixin jpeg_common_fields!();

    jpeg_destination_mgr* dest;

    JDIMENSION image_width;
    JDIMENSION image_height;
    int input_components;
    J_COLOR_SPACE in_color_space;

    double input_gamma;

    static if (JPEG_LIB_VERSION >= 70)
    {
        uint scale_num, scale_denom;

        JDIMENSION jpeg_width;
        JDIMENSION jpeg_height;
    }

    int data_precision;

    int num_components;
    J_COLOR_SPACE jpeg_color_space;

    jpeg_component_info* comp_info;

    JQUANT_TBL*[NUM_QUANT_TBLS] quant_tbl_ptrs;

    static if (JPEG_LIB_VERSION >= 70)
    {
        int[NUM_QUANT_TBLS] q_scale_factor;
    }

    JHUFF_TBL*[NUM_HUFF_TBLS] dc_huff_tbl_ptrs;
    JHUFF_TBL*[NUM_HUFF_TBLS] ac_huff_tbl_ptrs;

    UINT8[NUM_ARITH_TBLS] arith_dc_L;
    UINT8[NUM_ARITH_TBLS] arith_dc_U;
    UINT8[NUM_ARITH_TBLS] arith_ac_K;

    int num_scans;
    const jpeg_scan_info* scan_info;

    boolean raw_data_in;
    boolean arith_code;
    boolean optimize_coding;
    boolean CCIR601_sampling;
    static if (JPEG_LIB_VERSION >= 70)
    {
        boolean do_fancy_downsampling;
    }
    int smoothing_factor;
    J_DCT_METHOD dct_method;

    uint restart_interval;
    int restart_in_rows;

    boolean write_JFIF_header;
    UINT8 JFIF_major_version;
    UINT8 JFIF_minor_version;
    UINT8 density_unit;
    UINT16 X_density;
    UINT16 Y_density;
    boolean write_Adobe_marker;

    JDIMENSION next_scanline;

    boolean progressive_mode;
    int max_h_samp_factor;
    int max_v_samp_factor;

    static if (JPEG_LIB_VERSION >= 70)
    {
        int min_DCT_h_scaled_size;
        int min_DCT_v_scaled_size;
    }

    JDIMENSION total_iMCU_rows;

    int comps_in_scan;
    jpeg_component_info*[MAX_COMPS_IN_SCAN] cur_comp_info;

    JDIMENSION MCUs_per_row;
    JDIMENSION MCU_rows_in_scan;

    int blocks_in_MCU;
    int[C_MAX_BLOCKS_IN_MCU] MCU_membership;

    int Ss, Se, Ah, Al;

    static if (JPEG_LIB_VERSION >= 80)
    {
        int block_size;
        const int* natural_order;
        int lim_Se;
    }

    jpeg_comp_master* master;
    jpeg_c_main_controller* main;
    jpeg_c_prep_controller* prep;
    jpeg_c_coef_controller* coef;
    jpeg_marker_writer* marker;
    jpeg_color_converter* cconvert;
    jpeg_downsampler* downsample;
    jpeg_forward_dct* fdct;
    jpeg_entropy_encoder* entropy;
    jpeg_scan_info* script_space;
    int script_space_size;
}

struct jpeg_decompress_struct
{
    mixin jpeg_common_fields!();

    jpeg_source_mgr* src;

    JDIMENSION image_width;
    JDIMENSION image_height;
    int num_components;
    J_COLOR_SPACE jpeg_color_space;

    J_COLOR_SPACE out_color_space;

    uint scale_num, scale_denom;

    double output_gamma;

    boolean buffered_image;
    boolean raw_data_out;

    J_DCT_METHOD dct_method;
    boolean do_fancy_upsampling;
    boolean do_block_smoothing;

    boolean quantize_colors;

    J_DITHER_MODE dither_mode;
    boolean two_pass_quantize;
    int desired_number_of_colors;

    boolean enable_1pass_quant;
    boolean enable_external_quant;
    boolean enable_2pass_quant;

    JDIMENSION output_width;
    JDIMENSION output_height;
    int out_color_components;
    int output_components;
    int rec_outbuf_height;

    int actual_number_of_colors;
    JSAMPARRAY colormap;

    JDIMENSION output_scanline;

    int input_scan_number;
    JDIMENSION input_iMCU_row;

    int output_scan_number;
    JDIMENSION output_iMCU_row;

    int[DCTSIZE2]* coef_bits;

    JQUANT_TBL*[NUM_QUANT_TBLS] quant_tbl_ptrs;

    JHUFF_TBL*[NUM_QUANT_TBLS] dc_huff_tbl_ptrs;
    JHUFF_TBL*[NUM_QUANT_TBLS] ac_huff_tbl_ptrs;

    int data_precision;

    jpeg_component_info* comp_info;

    static if (JPEG_LIB_VERSION >= 80)
    {
        boolean is_baseline;
    }
    boolean progressive_mode;
    boolean arith_code;

    UINT8[NUM_ARITH_TBLS] arith_dc_L;
    UINT8[NUM_ARITH_TBLS] arith_dc_U;
    UINT8[NUM_ARITH_TBLS] arith_ac_K;

    uint restart_interval;

    boolean saw_JFIF_marker;

    UINT8 JFIF_major_version;
    UINT8 JFIF_minor_version;
    UINT8 density_unit;
    UINT16 X_density;
    UINT16 Y_density;
    boolean saw_Adobe_marker;
    UINT8 Adobe_transform;

    boolean CCIR601_sampling;

    jpeg_saved_marker_ptr marker_list;

    int max_h_samp_factor;
    int max_v_samp_factor;

    static if (JPEG_LIB_VERSION >= 70)
    {
        int min_DCT_h_scaled_size;
        int min_DCT_v_scaled_size;
    }
    else
    {
        int min_DCT_scaled_size;
    }

    JDIMENSION total_iMCU_rows;

    JSAMPLE* sample_range_limit;

    int comps_in_scan;
    jpeg_component_info*[MAX_COMPS_IN_SCAN] cur_comp_info;

    JDIMENSION MCUs_per_row;
    JDIMENSION MCU_rows_in_scan;

    int blocks_in_MCU;
    int[D_MAX_BLOCKS_IN_MCU] MCU_membership;

    int Ss, Se, Ah, Al;

    static if (JPEG_LIB_VERSION >= 80)
    {
        int block_size;
        const int* natural_order;
        int lim_Se;
    }

    int unread_marker;

    jpeg_decomp_master* master;
    jpeg_d_main_controller* main;
    jpeg_d_coef_controller* coef;
    jpeg_d_post_controller* post;
    jpeg_input_controller* inputctl;
    jpeg_marker_reader* marker;
    jpeg_entropy_decoder* entropy;
    jpeg_inverse_dct* idct;
    jpeg_upsampler* upsample;
    jpeg_color_deconverter* cconvert;
    jpeg_color_quantizer* cquantize;
}

enum JMSG_LENGTH_MAX = 200;
enum JMSG_STR_PARM_MAX = 80;

struct jpeg_error_mgr
{
    void function(j_common_ptr cinfo) error_exit;
    void function(j_common_ptr cinfo, int msg_level) emit_message;
    void function(j_common_ptr cinfo) output_message;
    void function(j_common_ptr cinfo, char* buffer) format_message;
    void function(j_common_ptr cinfo) reset_error_mgr;

    int msg_code;
    static union msg_param_t
    {
        int[8] i;
        char[JMSG_STR_PARM_MAX] s;
    }

    msg_param_t msg_param;

    int trace_level;

    c_long num_warnings;

    const(char*)* jpeg_message_table;
    int last_jpeg_message;
    const(char*)* addon_message_table;
    int first_addon_message;
    int last_addon_message;
}

struct jpeg_progress_mgr
{
    void function(j_common_ptr cinfo) progress_monitor;

    c_long pass_counter;
    c_long pass_limit;
    int completed_passes;
    int total_passes;
}

struct jpeg_destination_mgr
{
    JOCTET* next_output_byte;
    size_t free_in_buffer;

    void function(j_compress_ptr cinfo) init_destination;
    boolean function(j_compress_ptr cinfo) empty_output_buffer;
    void function(j_compress_ptr cinfo) term_destination;
}

struct jpeg_source_mgr
{
    const JOCTET* next_input_byte;
    size_t bytes_in_buffer;

    void function(j_decompress_ptr cinfo) init_source;
    boolean function(j_decompress_ptr cinfo) fill_input_buffer;
    void function(j_decompress_ptr cinfo, c_long num_bytes) skip_input_data;
    boolean function(j_decompress_ptr cinfo, int desired) resync_to_restart;
    void function(j_decompress_ptr cinfo) term_source;
}

enum JPOOL_PERMANENT = 0;
enum JPOOL_IMAGE = 1;
enum JPOOL_NUMPOOLS = 2;

alias jvirt_sarray_ptr = jvirt_sarray_control*;
alias jvirt_barray_ptr = jvirt_barray_control*;

struct jpeg_memory_mgr
{
    void* function(j_common_ptr cinfo, int pool_id, size_t sizeofobject) alloc_small;
    void* function(j_common_ptr cinfo, int pool_id, size_t sizeofobject) alloc_large;
    JSAMPARRAY function(j_common_ptr cinfo, int pool_id,
            JDIMENSION samplesperrow, JDIMENSION numrows) alloc_sarray;
    JBLOCKARRAY function(j_common_ptr cinfo, int pool_id,
            JDIMENSION blocksperrow, JDIMENSION numrows) alloc_barray;
    jvirt_sarray_ptr function(j_common_ptr cinfo, int pool_id, boolean pre_zero,
            JDIMENSION samplesperrow, JDIMENSION numrows, JDIMENSION maxaccess) request_virt_sarray;
    jvirt_barray_ptr function(j_common_ptr cinfo, int pool_id, boolean pre_zero,
            JDIMENSION blocksperrow, JDIMENSION numrows, JDIMENSION maxaccess) request_virt_barray;
    void function(j_common_ptr cinfo) realize_virt_arrays;
    JSAMPARRAY function(j_common_ptr cinfo, jvirt_sarray_ptr ptr,
            JDIMENSION start_row, JDIMENSION num_rows, boolean writable) access_virt_sarray;
    JBLOCKARRAY function(j_common_ptr cinfo, jvirt_barray_ptr ptr,
            JDIMENSION start_row, JDIMENSION num_rows, boolean writable) access_virt_barray;
    void function(j_common_ptr cinfo, int pool_id) free_pool;
    void function(j_common_ptr cinfo) self_destruct;

    c_long max_memory_to_use;

    c_long max_alloc_chunk;
}

alias jpeg_marker_parser_method = boolean function(j_decompress_ptr cinfo);

jpeg_error_mgr* jpeg_std_error(jpeg_error_mgr* err);

extern (D) auto jpeg_create_compress(j_compress_ptr cinfo)
{
    jpeg_CreateCompress(cinfo, JPEG_LIB_VERSION, jpeg_compress_struct.sizeof);
}

extern (D) auto jpeg_create_decompress(j_decompress_ptr cinfo)
{
    jpeg_CreateDecompress(cinfo, JPEG_LIB_VERSION, jpeg_decompress_struct.sizeof);
}

void jpeg_CreateCompress(j_compress_ptr cinfo, int ver, size_t structsize);
void jpeg_CreateDecompress(j_decompress_ptr cinfo, int ver, size_t structsize);

void jpeg_destroy_compress(j_compress_ptr cinfo);
void jpeg_destroy_decompress(j_decompress_ptr cinfo);

void jpeg_stdio_dest(j_compress_ptr cinfo, FILE* outfile);
void jpeg_stdio_src(j_decompress_ptr cinfo, FILE* infile);

static if (JPEG_LIB_VERSION >= 80 || MEM_SRCDST_SUPPORTED)
{
    void jpeg_mem_dest(j_compress_ptr cinfo, ubyte** outbuffer, c_ulong* outsize);
    void jpeg_mem_src(j_decompress_ptr cinfo, const(ubyte)* inbuffer, c_ulong insize);
}

void jpeg_set_defaults(j_compress_ptr cinfo);

void jpeg_set_colorspace(j_compress_ptr cinfo, J_COLOR_SPACE colorspace);
void jpeg_default_colorspace(j_compress_ptr cinfo);
void jpeg_set_quality(j_compress_ptr cinfo, int quality, boolean force_baseline);
void jpeg_set_linear_quality(j_compress_ptr cinfo, int scale_factor, boolean force_baseline);

static if (JPEG_LIB_VERSION >= 70)
{
    void jpeg_default_qtables(j_compress_ptr cinfo, boolean force_baseline);
}

void jpeg_add_quant_table(j_compress_ptr cinfo, int which_tbl,
        const uint* basic_table, int scale_factor, boolean force_baseline);

int jpeg_quality_scaling(int quality);
void jpeg_simple_progression(j_compress_ptr cinfo);
void jpeg_suppress_tables(j_compress_ptr cinfo, boolean suppress);
JQUANT_TBL* jpeg_alloc_quant_table(j_common_ptr cinfo);
JHUFF_TBL* jpeg_alloc_huff_table(j_common_ptr cinfo);

void jpeg_start_compress(j_compress_ptr cinfo, boolean write_all_tables);
JDIMENSION jpeg_write_scanlines(j_compress_ptr cinfo, JSAMPARRAY scanlines, JDIMENSION num_lines);
void jpeg_finish_compress(j_compress_ptr cinfo);

static if (JPEG_LIB_VERSION >= 70)
{
    void jpeg_calc_jpeg_dimensions(j_compress_ptr cinfo);
}

JDIMENSION jpeg_write_raw_data(j_compress_ptr cinfo, JSAMPIMAGE data, JDIMENSION num_lines);

void jpeg_write_marker(j_compress_ptr cinfo, int marker, const JOCTET* dataptr, uint datalen);

void jpeg_write_m_header(j_compress_ptr cinfo, int marker, uint datalen);
void jpeg_write_m_byte(j_compress_ptr cinfo, int val);

void jpeg_write_tables(j_compress_ptr cinfo);

void jpeg_write_icc_profile(j_compress_ptr cinfo, const JOCTET* icc_data_ptr, uint icc_data_len);

int jpeg_read_header(j_decompress_ptr cinfo, boolean require_image);

enum JPEG_SUSPENDED = 0;
enum JPEG_HEADER_OK = 1;
enum JPEG_HEADER_TABLES_ONLY = 2;

boolean jpeg_start_decompress(j_decompress_ptr cinfo);
JDIMENSION jpeg_read_scanlines(j_decompress_ptr cinfo, JSAMPARRAY scanlines, JDIMENSION max_lines);
JDIMENSION jpeg_skip_scanlines(j_decompress_ptr cinfo, JDIMENSION num_lines);
void jpeg_crop_scanline(j_decompress_ptr cinfo, JDIMENSION* xoffset, JDIMENSION* width);
boolean jpeg_finish_decompress(j_decompress_ptr cinfo);

JDIMENSION jpeg_read_raw_data(j_decompress_ptr cinfo, JSAMPIMAGE data, JDIMENSION max_lines);

boolean jpeg_has_multiple_scans(j_decompress_ptr cinfo);
boolean jpeg_start_output(j_decompress_ptr cinfo, int scan_number);
boolean jpeg_finish_output(j_decompress_ptr cinfo);
boolean jpeg_input_complete(j_decompress_ptr cinfo);
void jpeg_new_colormap(j_decompress_ptr cinfo);
int jpeg_consume_input(j_decompress_ptr cinfo);

enum JPEG_REACHED_SOS = 1;
enum JPEG_REACHED_EOI = 2;
enum JPEG_ROW_COMPLETED = 3;
enum JPEG_SCAN_COMPLETED = 4;

static if (JPEG_LIB_VERSION >= 80)
{
    void jpeg_core_output_dimensions(j_decompress_ptr cinfo);
}
else
{
    void jpeg_calc_output_dimensions(j_decompress_ptr cinfo);
}

void jpeg_save_markers(j_decompress_ptr cinfo, int marker_code, uint length_limit);

void jpeg_set_marker_processor(j_decompress_ptr cinfo, int marker_code,
        jpeg_marker_parser_method routine);

jvirt_barray_ptr* jpeg_read_coefficients(j_decompress_ptr cinfo);
void jpeg_write_coefficients(j_compress_ptr cinfo, jvirt_barray_ptr* coef_arrays);
void jpeg_copy_critical_parameters(j_decompress_ptr srcinfo, j_compress_ptr dstinfo);

void jpeg_abort_compress(j_compress_ptr cinfo);
void jpeg_abort_decompress(j_decompress_ptr cinfo);

void jpeg_abort(j_common_ptr cinfo);
void jpeg_destroy(j_common_ptr cinfo);

boolean jpeg_resync_to_restart(j_decompress_ptr cinfo, int desired);

boolean jpeg_read_icc_profile(j_decompress_ptr cinfo, JOCTET** icc_data_ptr, uint* icc_data_len);

enum JPEG_RST0 = 0xD0;
enum JPEG_EOI = 0xD9;
enum JPEG_APP0 = 0xE0;
enum JPEG_COM = 0xFE;
