package spv_cross

import "core:c"

when ODIN_OS == .Windows 
{
  foreign import spvc {
    "./spirv-cross-c.lib",
    "./spirv-cross-core.lib",
    "./spirv-cross-glsl.lib",
    "./spirv-cross-hlsl.lib",
    "./spirv-cross-msl.lib",
    "./spirv-cross-reflect.lib",
    "./spirv-cross-cpp.lib",
  }
}
else when ODIN_OS == .Linux
{
  foreign import spvc {
    "./libspirv-cross-c.a",
    "./libspirv-cross-core.a",
    "./libspirv-cross-glsl.a",
    "./libspirv-cross-hlsl.a",
    "./libspirv-cross-msl.a",
    "./libspirv-cross-reflect.a",
    "./libspirv-cross-cpp.a",
  }
}

ctx              :: distinct rawptr;
parsed_ir        :: distinct rawptr;
compiler         :: distinct rawptr;
compiler_options :: distinct rawptr;
type             :: distinct rawptr;
resources        :: distinct rawptr;
constant         :: distinct rawptr;
set              :: distinct rawptr;

type_id     :: SpvId;
variable_id :: SpvId;
constant_id :: SpvId;

reflected_resource :: struct
{
  id: variable_id,
  base_type_id: type_id,
  type_id: type_id,
  name: cstring,
}

reflected_builtin_resource :: struct
{
  builtin: SpvBuiltIn,
  id: variable_id,
  resource: reflected_resource,
}

/* See C++ API. */
entry_point :: struct
{
  execution_model: SpvExecutionModel,
	name: cstring,
};

/* See C++ API. */
combined_image_sampler :: struct
{
  combined_id: variable_id,
  image_id: variable_id,
  sampler_id: variable_id,
};

/* See C++ API. */
specialization_constant :: struct
{
  id: constant_id,
  constant_id: c.uint,
};

/* See C++ API. */
buffer_range :: struct
{
  index: c.uint,
	offset: c.int,
  range: c.int,
};

/* See C++ API. */
hlsl_root_constants :: struct
{
  start: c.int,
	end: c.int,
	binding: c.int,
	space: c.int,
};

/* See C++ API. */
hlsl_vertex_attribute_remap :: struct
{
  location: c.uint,
	semantic: cstring,
};

TRUE :: true;
FALSE :: false;

result :: enum
{
	/* Success. */
	SUCCESS = 0,

	/* The SPIR-V is invalid. Should have been caught by validation ideally. */
	ERROR_INVALID_SPIRV = -1,

	/* The SPIR-V might be valid or invalid, but SPIRV-Cross currently cannot correctly translate this to your target language. */
	ERROR_UNSUPPORTED_SPIRV = -2,

	/* If for some reason we hit this, new or malloc failed. */
	ERROR_OUT_OF_MEMORY = -3,

	/* Invalid API argument. */
	ERROR_INVALID_ARGUMENT = -4,

	ERROR_INT_MAX = 0x7fffffff,
};

capture_mode :: enum
{
	/* The Parsed IR payload will be copied, and the handle can be reused to create other compiler instances. */
	COPY = 0,

	/*
	 * The payload will now be owned by the compiler.
	 * parsed_ir should now be considered a dead blob and must not be used further.
	 * This is optimal for performance and should be the go-to option.
	 */
	TAKE_OWNERSHIP = 1,

	INT_MAX = 0x7fffffff,
};

backend :: enum
{
	/* This backend can only perform reflection, no compiler options are supported. Maps to spirv_cross::Compiler. */
	NONE = 0,
	GLSL = 1, /* spirv_cross::CompilerGLSL */
	HLSL = 2, /* CompilerHLSL */
	MSL = 3, /* CompilerMSL */
	CPP = 4, /* CompilerCPP */
	JSON = 5, /* CompilerReflection w/ JSON backend */
	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
resource_type :: enum
{
	UNKNOWN = 0,
	UNIFORM_BUFFER = 1,
	STORAGE_BUFFER = 2,
	STAGE_INPUT = 3,
	STAGE_OUTPUT = 4,
	SUBPASS_INPUT = 5,
	STORAGE_IMAGE = 6,
	SAMPLED_IMAGE = 7,
	ATOMIC_COUNTER = 8,
	PUSH_CONSTANT = 9,
	SEPARATE_IMAGE = 10,
	SEPARATE_SAMPLERS = 11,
	ACCELERATION_STRUCTURE = 12,
	RAY_QUERY = 13,
	SHADER_RECORD_BUFFER = 14,
	INT_MAX = 0x7fffffff,
};

builtin_resource_type :: enum
{
	UNKNOWN = 0,
	STAGE_INPUT = 1,
	STAGE_OUTPUT = 2,
	INT_MAX = 0x7fffffff,
};

/* Maps to spirv_cross::SPIRType::BaseType. */
basetype :: enum
{
	UNKNOWN = 0,
	VOID = 1,
	BOOLEAN = 2,
	INT8 = 3,
	UINT8 = 4,
	INT16 = 5,
	UINT16 = 6,
	INT32 = 7,
	UINT32 = 8,
	INT64 = 9,
	UINT64 = 10,
	ATOMIC_COUNTER = 11,
	FP16 = 12,
	FP32 = 13,
	FP64 = 14,
	STRUCT = 15,
	IMAGE = 16,
	SAMPLED_IMAGE = 17,
	SAMPLER = 18,
	ACCELERATION_STRUCTURE = 19,

	INT_MAX = 0x7fffffff,
};

compiler_option :: distinct c.int;

COMPILER_OPTION_COMMON_BIT :: 0x1000000;
COMPILER_OPTION_GLSL_BIT :: 0x2000000;
COMPILER_OPTION_HLSL_BIT :: 0x4000000;
COMPILER_OPTION_MSL_BIT :: 0x8000000;
COMPILER_OPTION_LANG_BITS :: 0x0f000000;
COMPILER_OPTION_ENUM_BITS :: 0xffffff;


MAKE_MSL_VERSION :: proc(major, minor, patch: c.uint) -> c.uint
{
  return (major) * 10000 + (minor) * 100 + (patch);
}

/* Maps to C++ API. */
msl_platform :: enum
{
	PLATFORM_IOS = 0,
	PLATFORM_MACOS = 1,
	PLATFORM_MAX_INT = 0x7fffffff,
};

/* Maps to C++ API. */
msl_index_type :: enum
{
	TYPE_NONE = 0,
	TYPE_UINT16 = 1,
	TYPE_UINT32 = 2,
	TYPE_MAX_INT = 0x7fffffff,
};

/* Maps to C++ API. */
msl_shader_variable_format :: enum
{
	OTHER = 0,
	UINT8 = 1,
	UINT16 = 2,
	ANY16 = 3,
	ANY32 = 4,

	/* Deprecated names. */
	VERTEX_FORMAT_OTHER = OTHER,
	VERTEX_FORMAT_UINT8 = UINT8,
	VERTEX_FORMAT_UINT16 = UINT16,
	INPUT_FORMAT_OTHER = OTHER,
	INPUT_FORMAT_UINT8 = UINT8,
	INPUT_FORMAT_UINT16 = UINT16,
	INPUT_FORMAT_ANY16 = ANY16,
	INPUT_FORMAT_ANY32 = ANY32,

	INPUT_FORMAT_INT_MAX = 0x7fffffff,
};

msl_shader_input_format :: distinct msl_shader_variable_format;
msl_vertex_format :: distinct msl_shader_variable_format;

/* Maps to C++ API. Deprecated; use spvc_msl_shader_interface_var. */
msl_vertex_attribute :: struct
{
  location: c.uint,

	/* Obsolete, do not use. Only lingers on for ABI compatibility. */
	msl_buffer: c.uint,
	/* Obsolete, do not use. Only lingers on for ABI compatibility. */
	msl_offset: c.uint,
	/* Obsolete, do not use. Only lingers on for ABI compatibility. */
	msl_stride: c.uint,
	/* Obsolete, do not use. Only lingers on for ABI compatibility. */
	per_instance: bool,

	format: msl_vertex_format,
	builtin: SpvBuiltIn,
};
/* Maps to C++ API. Deprecated; use spvc_msl_shader_interface_var_2. */
msl_shader_interface_var :: struct
{
  location: c.uint,
	format: msl_vertex_format,
	builtin: SpvBuiltIn,
	vecsize: c.uint,
};
msl_shader_input :: distinct msl_shader_interface_var;

/* Maps to C++ API. */
msl_shader_variable_rate :: enum
{
	PER_VERTEX = 0,
	PER_PRIMITIVE = 1,
	PER_PATCH = 2,

	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_shader_interface_var_2 :: struct
{
  location: c.uint,
	format: msl_shader_variable_format,
	builtin: SpvBuiltIn,
	vecsize: c.uint,
	rate: msl_shader_variable_rate,
};

/* Maps to C++ API. */
msl_resource_binding :: struct
{
  stage: SpvExecutionModel,
	desc_set: c.uint,
	binding: c.uint,
	msl_buffer: c.uint,
	msl_texture: c.uint,
	msl_sampler: c.uint,
};

PUSH_CONSTANT_DESC_SET :: ~u32(0);

PUSH_CONSTANT_BINDING :: 0;
SWIZZLE_BUFFER_BINDING :: ~u32(1);
BUFFER_SIZE_BUFFER_BINDING :: ~u32(2);
ARGUMENT_BUFFER_BINDING :: ~u32(3);

/* Obsolete. Sticks around for backwards compatibility. */
AUX_BUFFER_STRUCT_VERSION :: 1

/* Maps to C++ API. */
msl_sampler_coord :: enum
{
	NORMALIZED = 0,
	PIXEL = 1,
	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_sampler_filter :: enum
{
	NEAREST = 0,
	LINEAR = 1,
	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_sampler_mip_filter :: enum
{
	NONE = 0,
	NEAREST = 1,
	LINEAR = 2,
	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_sampler_address :: enum
{
	CLAMP_TO_ZERO = 0,
	CLAMP_TO_EDGE = 1,
	CLAMP_TO_BORDER = 2,
	REPEAT = 3,
	MIRRORED_REPEAT = 4,
	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_sampler_compare_func :: enum
{
	NEVER = 0,
	LESS = 1,
	LESS_EQUAL = 2,
	GREATER = 3,
	GREATER_EQUAL = 4,
	EQUAL = 5,
	NOT_EQUAL = 6,
	ALWAYS = 7,
	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_sampler_border_color :: enum
{
	TRANSPARENT_BLACK = 0,
	OPAQUE_BLACK = 1,
	OPAQUE_WHITE = 2,
	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_format_resolution :: enum
{
	RESOLUTION_444 = 0,
	RESOLUTION_422,
	RESOLUTION_420,
	RESOLUTION_INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_chroma_location :: enum
{
	COSITED_EVEN = 0,
	MIDPOINT,
	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_component_swizzle :: enum
{
	IDENTITY = 0,
	ZERO,
	ONE,
	R,
	G,
	B,
	A,
	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_sampler_ycbcr_model_conversion :: enum
{
	RGB_IDENTITY = 0,
	YCBCR_IDENTITY,
	YCBCR_BT_709,
	YCBCR_BT_601,
	YCBCR_BT_2020,
	INT_MAX = 0x7fffffff,
};

/* Maps to C+ API. */
msl_sampler_ycbcr_range :: enum
{
	ITU_FULL = 0,
	ITU_NARROW,
	INT_MAX = 0x7fffffff,
};

/* Maps to C++ API. */
msl_constexpr_sampler :: struct
{
  coord: msl_sampler_coord,
	min_filter: msl_sampler_filter,
	mag_filter: msl_sampler_filter,
	mip_filter: msl_sampler_mip_filter,
  s_address: msl_sampler_address,
	t_address: msl_sampler_address,
	r_address: msl_sampler_address,
	compare_func: msl_sampler_compare_func,
	border_color: msl_sampler_border_color,
	lod_clamp_min: f32,
  lod_clamp_max: f32,
	max_anisotropy: c.int,

	compare_enable: bool,
  lod_clamp_enable: bool,
  anisotropy_enable: bool,
};

/* Maps to the sampler Y'CbCr conversion-related portions of MSLConstexprSampler. See C++ API for defaults and details. */
msl_sampler_ycbcr_conversion :: struct
{
  planes: c.uint,
	resolution: msl_format_resolution,
	chroma_filter: msl_sampler_filter,
	x_chroma_offset: msl_chroma_location,
	y_chroma_offset: msl_chroma_location,
	swizzle: [4]msl_component_swizzle,
	ycbcr_model: msl_sampler_ycbcr_model_conversion,
	ycbcr_range: msl_sampler_ycbcr_range,
	bpc: c.uint,
};

hlsl_binding_flags :: distinct c.int;

HLSL_BINDING_AUTO_PUSH_CONSTANT_BIT :: 1 << 0;
HLSL_BINDING_AUTO_CBV_BIT :: 1 << 1;
HLSL_BINDING_AUTO_SRV_BIT :: 1 << 2;
HLSL_BINDING_AUTO_UAV_BIT :: 1 << 3;
HLSL_BINDING_AUTO_SAMPLER_BIT :: 1 << 4;
HLSL_BINDING_AUTO_ALL :: 0x7fffffff;

HLSL_PUSH_CONSTANT_DESC_SET :: ~u32(0)
HLSL_PUSH_CONSTANT_BINDING :: 0

/* Maps to C++ API. */
hlsl_resource_binding_mapping :: struct
{
  register_space: c.uint,
	register_binding: c.uint,
};

hlsl_resource_binding :: struct
{
  stage: SpvExecutionModel,
	desc_set: c.uint,
  binding: c.uint,
	cbv, uav, srv, sampler: hlsl_resource_binding_mapping,
};

/* Maps to the various spirv_cross::Compiler*::Option structures. See C++ API for defaults and details. */
COMPILER_OPTION_UNKNOWN :: 0;

COMPILER_OPTION_FORCE_TEMPORARY :: 1 | COMPILER_OPTION_COMMON_BIT;

COMPILER_OPTION_FLATTEN_MULTIDIMENSIONAL_ARRAYS :: 2 | COMPILER_OPTION_COMMON_BIT;
COMPILER_OPTION_FIXUP_DEPTH_CONVENTION :: 3 | COMPILER_OPTION_COMMON_BIT;
COMPILER_OPTION_FLIP_VERTEX_Y :: 4 | COMPILER_OPTION_COMMON_BIT;

COMPILER_OPTION_GLSL_SUPPORT_NONZERO_BASE_INSTANCE :: 5 | COMPILER_OPTION_GLSL_BIT;
COMPILER_OPTION_GLSL_SEPARATE_SHADER_OBJECTS :: 6 | COMPILER_OPTION_GLSL_BIT;
COMPILER_OPTION_GLSL_ENABLE_420PACK_EXTENSION :: 7 | COMPILER_OPTION_GLSL_BIT;
COMPILER_OPTION_GLSL_VERSION :: 8 | COMPILER_OPTION_GLSL_BIT;
COMPILER_OPTION_GLSL_ES :: 9 | COMPILER_OPTION_GLSL_BIT;
COMPILER_OPTION_GLSL_VULKAN_SEMANTICS :: 10 | COMPILER_OPTION_GLSL_BIT;
COMPILER_OPTION_GLSL_ES_DEFAULT_FLOAT_PRECISION_HIGHP :: 11 | COMPILER_OPTION_GLSL_BIT;
COMPILER_OPTION_GLSL_ES_DEFAULT_INT_PRECISION_HIGHP :: 12 | COMPILER_OPTION_GLSL_BIT;

COMPILER_OPTION_HLSL_SHADER_MODEL :: 13 | COMPILER_OPTION_HLSL_BIT;
COMPILER_OPTION_HLSL_POINT_SIZE_COMPAT :: 14 | COMPILER_OPTION_HLSL_BIT;
COMPILER_OPTION_HLSL_POINT_COORD_COMPAT :: 15 | COMPILER_OPTION_HLSL_BIT;
COMPILER_OPTION_HLSL_SUPPORT_NONZERO_BASE_VERTEX_BASE_INSTANCE :: 16 | COMPILER_OPTION_HLSL_BIT;

COMPILER_OPTION_MSL_VERSION :: 17 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_TEXEL_BUFFER_TEXTURE_WIDTH :: 18 | COMPILER_OPTION_MSL_BIT;

/* Obsolete; use SWIZZLE_BUFFER_INDEX instead. */
COMPILER_OPTION_MSL_AUX_BUFFER_INDEX :: 19 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_SWIZZLE_BUFFER_INDEX :: 19 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_MSL_INDIRECT_PARAMS_BUFFER_INDEX :: 20 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_SHADER_OUTPUT_BUFFER_INDEX :: 21 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_SHADER_PATCH_OUTPUT_BUFFER_INDEX :: 22 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_SHADER_TESS_FACTOR_OUTPUT_BUFFER_INDEX :: 23 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_SHADER_INPUT_WORKGROUP_INDEX :: 24 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_ENABLE_POINT_SIZE_BUILTIN :: 25 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_DISABLE_RASTERIZATION :: 26 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_CAPTURE_OUTPUT_TO_BUFFER :: 27 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_SWIZZLE_TEXTURE_SAMPLES :: 28 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_PAD_FRAGMENT_OUTPUT_COMPONENTS :: 29 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_TESS_DOMAIN_ORIGIN_LOWER_LEFT :: 30 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_PLATFORM :: 31 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_ARGUMENT_BUFFERS :: 32 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_GLSL_EMIT_PUSH_CONSTANT_AS_UNIFORM_BUFFER :: 33 | COMPILER_OPTION_GLSL_BIT;

COMPILER_OPTION_MSL_TEXTURE_BUFFER_NATIVE :: 34 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_GLSL_EMIT_UNIFORM_BUFFER_AS_PLAIN_UNIFORMS :: 35 | COMPILER_OPTION_GLSL_BIT;

COMPILER_OPTION_MSL_BUFFER_SIZE_BUFFER_INDEX :: 36 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_EMIT_LINE_DIRECTIVES :: 37 | COMPILER_OPTION_COMMON_BIT;

COMPILER_OPTION_MSL_MULTIVIEW :: 38 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_VIEW_MASK_BUFFER_INDEX :: 39 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_DEVICE_INDEX :: 40 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_VIEW_INDEX_FROM_DEVICE_INDEX :: 41 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_DISPATCH_BASE :: 42 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_DYNAMIC_OFFSETS_BUFFER_INDEX :: 43 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_TEXTURE_1D_AS_2D :: 44 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_ENABLE_BASE_INDEX_ZERO :: 45 | COMPILER_OPTION_MSL_BIT;

/* Obsolete. Use MSL_FRAMEBUFFER_FETCH_SUBPASS instead. */
COMPILER_OPTION_MSL_IOS_FRAMEBUFFER_FETCH_SUBPASS :: 46 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_FRAMEBUFFER_FETCH_SUBPASS :: 46 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_MSL_INVARIANT_FP_MATH :: 47 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_EMULATE_CUBEMAP_ARRAY :: 48 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_ENABLE_DECORATION_BINDING :: 49 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_FORCE_ACTIVE_ARGUMENT_BUFFER_RESOURCES :: 50 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_FORCE_NATIVE_ARRAYS :: 51 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_ENABLE_STORAGE_IMAGE_QUALIFIER_DEDUCTION :: 52 | COMPILER_OPTION_COMMON_BIT;

COMPILER_OPTION_HLSL_FORCE_STORAGE_BUFFER_AS_UAV :: 53 | COMPILER_OPTION_HLSL_BIT;

COMPILER_OPTION_FORCE_ZERO_INITIALIZED_VARIABLES :: 54 | COMPILER_OPTION_COMMON_BIT;

COMPILER_OPTION_HLSL_NONWRITABLE_UAV_TEXTURE_AS_SRV :: 55 | COMPILER_OPTION_HLSL_BIT;

COMPILER_OPTION_MSL_ENABLE_FRAG_OUTPUT_MASK :: 56 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_ENABLE_FRAG_DEPTH_BUILTIN :: 57 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_ENABLE_FRAG_STENCIL_REF_BUILTIN :: 58 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_ENABLE_CLIP_DISTANCE_USER_VARYING :: 59 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_HLSL_ENABLE_16BIT_TYPES :: 60 | COMPILER_OPTION_HLSL_BIT;

COMPILER_OPTION_MSL_MULTI_PATCH_WORKGROUP :: 61 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_SHADER_INPUT_BUFFER_INDEX :: 62 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_SHADER_INDEX_BUFFER_INDEX :: 63 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_VERTEX_FOR_TESSELLATION :: 64 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_VERTEX_INDEX_TYPE :: 65 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_GLSL_FORCE_FLATTENED_IO_BLOCKS :: 66 | COMPILER_OPTION_GLSL_BIT;

COMPILER_OPTION_MSL_MULTIVIEW_LAYERED_RENDERING :: 67 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_ARRAYED_SUBPASS_INPUT :: 68 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_R32UI_LINEAR_TEXTURE_ALIGNMENT :: 69 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_R32UI_ALIGNMENT_CONSTANT_ID :: 70 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_HLSL_FLATTEN_MATRIX_VERTEX_INPUT_SEMANTICS :: 71 | COMPILER_OPTION_HLSL_BIT;

COMPILER_OPTION_MSL_IOS_USE_SIMDGROUP_FUNCTIONS :: 72 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_EMULATE_SUBGROUPS :: 73 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_FIXED_SUBGROUP_SIZE :: 74 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_FORCE_SAMPLE_RATE_SHADING :: 75 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_IOS_SUPPORT_BASE_VERTEX_INSTANCE :: 76 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_GLSL_OVR_MULTIVIEW_VIEW_COUNT :: 77 | COMPILER_OPTION_GLSL_BIT;

COMPILER_OPTION_RELAX_NAN_CHECKS :: 78 | COMPILER_OPTION_COMMON_BIT;

COMPILER_OPTION_MSL_RAW_BUFFER_TESE_INPUT :: 79 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_SHADER_PATCH_INPUT_BUFFER_INDEX :: 80 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_MANUAL_HELPER_INVOCATION_UPDATES :: 81 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_CHECK_DISCARDED_FRAG_STORES :: 82 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_GLSL_ENABLE_ROW_MAJOR_LOAD_WORKAROUND :: 83 | COMPILER_OPTION_GLSL_BIT;

COMPILER_OPTION_MSL_ARGUMENT_BUFFERS_TIER :: 84 | COMPILER_OPTION_MSL_BIT;
COMPILER_OPTION_MSL_SAMPLE_DREF_LOD_ARRAY_AS_GRAD :: 85 | COMPILER_OPTION_MSL_BIT;

COMPILER_OPTION_INT_MAX :: 0x7fffffff

error_callback :: #type proc "c" (userdata: rawptr, error: cstring);

@(default_calling_convention="c", link_prefix="spvc_")
foreign spvc 
{
  get_version :: proc(major: ^c.uint, minor: ^c.uint, patch: ^c.uint) ---
  get_commit_revision_and_timestamp :: proc() -> cstring ---
  /*
  * Initializes the vertex attribute struct.
  */
  msl_vertex_attribute_init :: proc(attr: ^msl_vertex_attribute) ---

  /*
  * Initializes the shader input struct.
  * Deprecated. Use spvc_msl_shader_interface_var_init_2().
  */
  msl_shader_interface_var_init :: proc(var: ^msl_shader_interface_var) ---
  /*
  * Deprecated. Use spvc_msl_shader_interface_var_init_2().
  */
  msl_shader_input_init :: proc(input: ^msl_shader_input) ---

  /*
  * Initializes the shader interface variable struct.
  */
  msl_shader_interface_var_init_2 :: proc(var: ^msl_shader_interface_var_2) ---

  /*
  * Initializes the resource binding struct.
  * The defaults are non-zero.
  */
  msl_resource_binding_init :: proc(binding: ^msl_resource_binding) ---

  /* Runtime check for incompatibility. Obsolete. */
  msl_get_aux_buffer_struct_version :: proc() -> c.uint ---


  /*
  * Initializes the constexpr sampler struct.
  * The defaults are non-zero.
  */
  msl_constexpr_sampler_init :: proc(sampler: ^msl_constexpr_sampler) ---
  /*
  * Initializes the constexpr sampler struct.
  * The defaults are non-zero.
  */
  msl_sampler_ycbcr_conversion_init :: proc(conv: ^msl_sampler_ycbcr_conversion) ---


  /*
  * Initializes the resource binding struct.
  * The defaults are non-zero.
  */
  hlsl_resource_binding_init :: proc(binding: ^hlsl_resource_binding) ---
  /*
  * Context is the highest-level API construct.
  * The context owns all memory allocations made by its child object hierarchy, including various non-opaque structs and strings.
  * This means that the API user only has to care about one "destroy" call ever when using the C API.
  * All pointers handed out by the APIs are only valid as long as the context
  * is alive and spvcctx_release_allocations has not been called.
  */
  context_create :: proc(ctx: ^ctx) -> result ---

  /* Frees all memory allocations and objects associated with the context and its child objects. */
  context_destroy :: proc(ctx: ctx) ---


  /* Frees all memory allocations and objects associated with the context and its child objects, but keeps the context alive. */
  context_release_allocations :: proc(ctx: ctx) ---

  /* Get the string for the last error which was logged. */
  context_get_last_error_string :: proc(ctx: ctx) ---

  /* Get notified in a callback when an error triggers. Useful for debugging. */
  context_set_error_callback :: proc(ctx: ctx, cb: error_callback, userdata: rawptr) ---

  /* SPIR-V parsing interface. Maps to Parser which then creates a ParsedIR, and that IR is extracted into the handle. */
  context_parse_spirv :: proc(ctx: ctx, spirv: ^SpvId, word_count: c.int, parsed_ir: ^parsed_ir) -> result ---


  /*
  * Create a compiler backend. Capture mode controls if we construct by copy or move semantics.
  * It is always recommended to use SPVC_CAPTURE_MODE_TAKE_OWNERSHIP if you only intend to cross-compile the IR once.
  */
  context_create_compiler :: proc(ctx: ctx, backend: backend, p_ir: parsed_ir, mode: capture_mode, cmplr: ^compiler) -> result ---

  /* Maps directly to C++ API. */
  compiler_get_current_id_bound :: proc(compiler: compiler) -> c.uint ---

  /* Create compiler options, which will initialize defaults. */
  compiler_create_compiler_options :: proc(compiler: compiler, options: ^compiler_options) -> result ---
  /* Override options. Will return error if e.g. MSL options are used for the HLSL backend, etc. */
  compiler_options_set_bool :: proc(options: compiler_options, option: compiler_option, value: bool) -> result ---
  compiler_options_set_uint :: proc(options: compiler_options, option: compiler_option, value: c.uint) -> result ---
  /* Set compiler options. */
  compiler_install_compiler_options :: proc(compiler: compiler, options: compiler_options) -> result ---

  /* Compile IR into a string. *source is owned by the context, and caller must not free it themselves. */
  compiler_compile :: proc(compiler: compiler, source: ^cstring) -> result ---

  /* Maps to C++ API. */
  compiler_add_header_line :: proc(compiler: compiler, line: cstring) -> result ---
  compiler_require_extension :: proc(compiler: compiler, ext: cstring) -> result ---
  compiler_flatten_buffer_block :: proc(compiler: compiler, id: variable_id) -> result ---

  compiler_variable_is_depth_or_compare :: proc(compiler: compiler, id: variable_id) -> bool ---

  compiler_mask_stage_output_by_location :: proc(compiler: compiler, location: c.uint, component: c.uint) -> result ---
  spvc_compiler_mask_stage_output_by_builtin :: proc(compiler: compiler, builtin: SpvBuiltIn) -> result ---

  /*
  * HLSL specifics.
  * Maps to C++ API.
  */
  compiler_hlsl_set_root_constants_layout :: proc(compiler: compiler, constant_info: ^hlsl_root_constants, count: c.int) -> result ---
  compiler_hlsl_add_vertex_attribute_remap :: proc(compiler: compiler, remap: ^hlsl_vertex_attribute_remap, remaps: c.int) -> result ---
  compiler_hlsl_remap_num_workgroups_builtin :: proc(compiler: compiler) -> variable_id ---

  compiler_hlsl_set_resource_binding_flags :: proc(compiler: compiler, flags: hlsl_binding_flags) -> result ---

  compiler_hlsl_add_resource_binding :: proc(compiler: compiler, binding: ^hlsl_resource_binding) -> result ---
  compiler_hlsl_is_resource_used :: proc(compiler: compiler, model: SpvExecutionModel, set: c.uint, binding: c.uint) -> bool ---
  /*
  * MSL specifics.
  * Maps to C++ API.

  */
  compiler_msl_is_rasterization_disabled :: proc(compiler: compiler) -> bool ---

  /* Obsolete. Renamed to needs_swizzle_buffer. */
  compiler_msl_needs_aux_buffer :: proc(compiler: compiler) -> bool ---
  compiler_msl_needs_swizzle_buffer :: proc(compiler: compiler) -> bool ---
  compiler_msl_needs_buffer_size_buffer :: proc(compiler: compiler) -> bool ---

  compiler_msl_needs_output_buffer :: proc(compiler: compiler) -> bool ---
  compiler_msl_needs_patch_output_buffer :: proc(compiler: compiler) -> bool ---
  compiler_msl_needs_input_threadgroup_mem :: proc(compiler: compiler) -> bool ---
  compiler_msl_add_vertex_attribute :: proc(compiler: compiler, attrs: msl_vertex_attribute) -> result ---
  compiler_msl_add_resource_binding :: proc(compiler: compiler, binding: ^msl_resource_binding) -> result ---
  /* Deprecated; use spvc_compiler_msl_add_shader_input_2(). */
  compiler_msl_add_shader_input :: proc(compiler: compiler, input: ^msl_shader_interface_var) -> result ---
  compiler_msl_add_shader_input_2 :: proc(compiler: compiler, input: ^msl_shader_interface_var_2) -> result ---
  /* Deprecated; use spvc_compiler_msl_add_shader_output_2(). */
  compiler_msl_add_shader_output :: proc(compiler: compiler, output: ^msl_shader_interface_var) -> result ---
  compiler_msl_add_shader_output_2 :: proc(compiler: compiler, output: ^msl_shader_interface_var_2) -> result ---
  compiler_msl_add_discrete_descriptor_set :: proc(compiler: compiler, desc_set: c.uint) -> result ---
  compiler_msl_set_argument_buffer_device_address_space :: proc(compiler: compiler, desc_set: c.uint, device_address: bool) -> result ---

  /* Obsolete, use is_shader_input_used. */
  compiler_msl_is_vertex_attribute_used :: proc(compiler: compiler, location: c.uint) -> bool ---
  compiler_msl_is_shader_input_used :: proc(compiler: compiler, location: c.uint) -> bool ---
  compiler_msl_is_shader_output_used :: proc(compiler: compiler, location: c.uint) -> bool ---

  compiler_msl_is_resource_used :: proc(compiler: compiler, model: SpvExecutionModel, set: c.uint, binding: c.uint) -> bool ---

  compiler_msl_remap_constexpr_sampler :: proc(compiler: compiler, id: variable_id, sampler: ^msl_constexpr_sampler) -> result ---
  compiler_msl_remap_constexpr_sampler_by_binding :: proc(compiler: compiler, desc_set: c.uint, binding: c.uint, sampler: ^msl_constexpr_sampler) -> result ---
  compiler_msl_remap_constexpr_sampler_ycbcr :: proc(compiler: compiler, id: variable_id, sampler: ^msl_constexpr_sampler, convL: ^msl_sampler_ycbcr_conversion) -> result ---
  compiler_msl_remap_constexpr_sampler_by_binding_ycbcr :: proc(compiler: compiler, desc_set: c.uint, binding: c.uint, sampler: ^msl_constexpr_sampler, conv: ^msl_sampler_ycbcr_conversion) -> result ---
  compiler_msl_set_fragment_output_components :: proc(compiler: compiler, location: c.uint, components: c.uint) -> result ---

  compiler_msl_get_automatic_resource_binding :: proc(compiler: compiler, id: variable_id)  -> c.uint ---
  compiler_msl_get_automatic_resource_binding_secondary :: proc(compiler: compiler, id: variable_id) -> c.uint ---

  compiler_msl_add_dynamic_buffer :: proc(compiler: compiler, desc_set: c.uint, binding: c.uint, index: c.uint) -> result ---

  compiler_msl_add_inline_uniform_block :: proc(compiler: compiler, desc_set: c.uint, binding: c.uint) -> result ---

  compiler_msl_set_combined_sampler_suffix :: proc(compiler: compiler, suffix: cstring) -> result ---
  compiler_msl_get_combined_sampler_suffix :: proc(compiler: compiler) -> cstring ---

  /*
  * Reflect resources.
  * Maps almost 1:1 to C++ API.
  */
  compiler_get_active_interface_variables :: proc(compiler: compiler, set: ^set) -> result ---
  compiler_set_enabled_interface_variables :: proc(compiler: compiler, set: set) -> result ---
  compiler_create_shader_resources :: proc(compiler: compiler, resources: ^resources) -> result ---
  compiler_create_shader_resources_for_active_variables :: proc(compiler: compiler, resources: ^resources, active: set) -> result ---
  resources_get_resource_list_for_type :: proc(resources: resources, type: resource_type, resource_list: ^^reflected_resource, resource_size: ^c.int) -> result ---

  resources_get_builtin_resource_list_for_type :: proc(resources: resources, type: builtin_resource_type, resource_list: [^]reflected_builtin_resource, resource_size: c.int) -> result ---

  /*
  * Decorations.
  * Maps to C++ API.
  */
  compiler_set_decoration :: proc(compiler: compiler, id: SpvId, decoration: SpvDecoration, argument: c.uint) ---
  compiler_set_decoration_string :: proc(compiler: compiler, id: SpvId, decoration: SpvDecoration, argument: cstring) ---
  compiler_set_name :: proc(compiler: compiler, id: SpvId, argument: cstring) ---
  compiler_set_member_decoration :: proc(compiler: compiler, id: type_id, member_index: c.uint, decoration: SpvDecoration, argument: c.uint) ---
  compiler_set_member_decoration_string :: proc(compiler: compiler, id: type_id, member_index: c.uint, decoration: SpvDecoration, argument: cstring) ---
  compiler_set_member_name :: proc(compiler: compiler, id: type_id, member_index: c.uint, argument: cstring) ---
  compiler_unset_decoration :: proc(compiler: compiler, id: SpvId, decoration: SpvDecoration) ---
  compiler_unset_member_decoration :: proc(compiler: compiler, id: type_id, member_index: c.uint, decoration: SpvDecoration) ---

  compiler_has_decoration :: proc(compiler: compiler, id: SpvId, decoration: SpvDecoration) -> bool ---
  compiler_has_member_decoration :: proc(compiler: compiler, id: type_id, member_index: c.uint, decoration: SpvDecoration) -> bool ---
  compiler_get_name :: proc(compiler: compiler, id: SpvId) -> cstring ---
  compiler_get_decoration :: proc(compiler: compiler, id: SpvId, decoration: SpvDecoration) -> c.uint ---
  compiler_get_decoration_string :: proc(compiler: compiler, id: SpvId, decoration: SpvDecoration) -> cstring ---
  compiler_get_member_decoration :: proc(compiler: compiler, id: type_id, member_index: c.uint, decoration: SpvDecoration) -> c.uint ---
  compiler_get_member_decoration_string :: proc(compiler: compiler, id: type_id, member_index: c.uint, decoration: SpvDecoration) -> cstring ---
  compiler_get_member_name :: proc(compiler: compiler, id: type_id, member_index: c.uint) -> cstring ---

  /*
  * Entry points.
  * Maps to C++ API.
  */
  compiler_get_entry_points :: proc(compiler: compiler, entry_points: [^]entry_point, num_entry_points: c.int) -> result ---
  compiler_set_entry_point :: proc(compiler: compiler, name: cstring, model: SpvExecutionModel) -> result ---
  compiler_rename_entry_point :: proc(compiler: compiler, old_name: cstring, new_name: cstring, model: SpvExecutionModel) -> result ---
  compiler_get_cleansed_entry_point_name :: proc(compiler: compiler, name: cstring, model: SpvExecutionModel) -> cstring ---
  compiler_set_execution_mode :: proc(compiler: compiler, mode: SpvExecutionMode) ---
  compiler_unset_execution_mode :: proc(compiler: compiler, mode: SpvExecutionMode) ---
  compiler_set_execution_mode_with_arguments :: proc(compiler: compiler, mode: SpvExecutionMode, arg0: c.uint, arg1: c.uint, arg2: c.uint) ---
  compiler_get_execution_modes :: proc(compiler: compiler, modes: [^]SpvExecutionMode, num_modes: c.int) -> result ---
  compiler_get_execution_mode_argument :: proc(compiler: compiler, mode: SpvExecutionMode) -> c.uint ---
  compiler_get_execution_mode_argument_by_index :: proc(compiler: compiler, mode: SpvExecutionMode, index: c.uint) -> c.uint ---
  compiler_get_execution_model :: proc(compiler: compiler) -> SpvExecutionModel ---
  compiler_update_active_builtins :: proc(compiler: compiler) ---
  compiler_has_active_builtin :: proc(compiler: compiler, builtin: SpvBuiltIn, storage: SpvStorageClass) -> bool ---

  /*
  * Type query interface.
  * Maps to C++ API, except it's read-only.
  */
  compiler_get_type_handle :: proc(compiler: compiler, id: type_id) -> type ---

  /* Pulls out SPIRType::self. This effectively gives the type ID without array or pointer qualifiers.
  * This is necessary when reflecting decoration/name information on members of a struct,
  * which are placed in the base type, not the qualified type.
  * This is similar to spvc_reflected_resource::base_type_id. */
  type_get_base_type_id :: proc(type: type) -> type_id ---

  type_get_basetype :: proc(type: type) -> basetype ---
  type_get_bit_width :: proc(type: type) -> c.uint ---
  type_get_vector_size :: proc(type: type) -> c.uint ---
  type_get_columns :: proc(type: type) -> c.uint ---
  type_get_num_array_dimensions :: proc(type: type) -> c.uint ---
  type_array_dimension_is_literal :: proc(type: type, dimension: c.uint) -> bool ---
  type_get_array_dimension :: proc(type: type, dimension: c.uint) -> SpvId ---
  type_get_num_member_types :: proc(type: type) -> c.uint ---
  type_get_member_type :: proc(typ: type, index: c.uint) -> type ---
  type_get_storage_class :: proc(type: type) -> SpvStorageClass ---

  /* Image type query. */
  type_get_image_sampled_type :: proc(type: type) -> type_id ---
  type_get_image_dimension :: proc(type: type) -> SpvDim --- 
  type_get_image_is_depth :: proc(type: type) -> bool ---
  type_get_image_arrayed :: proc(type: type) -> bool ---
  type_get_image_multisampled :: proc(type: type) -> bool ---
  type_get_image_is_storage :: proc(type: type) -> bool ---
  type_get_image_storage_format :: proc(type: type) -> SpvImageFormat ---
  type_get_image_access_qualifier :: proc(type: type) -> SpvAccessQualifier --- 

  /*
  * Buffer layout query.
  * Maps to C++ API.
  */
  compiler_get_declared_struct_size :: proc(compiler: compiler, struct_type: type, size: ^c.int) -> result ---
  compiler_get_declared_struct_size_runtime_array :: proc(compiler: compiler, struct_type: type, array_size: c.int, size: ^c.int) -> result ---
  compiler_get_declared_struct_member_size :: proc(compiler: compiler, type: type, index: c.uint, size: ^c.int) -> result ---

  compiler_type_struct_member_offset :: proc(compiler: compiler, type: type, index: c.uint, offset: ^c.uint) -> result ---
  compiler_type_struct_member_array_stride :: proc(compiler: compiler, type: type, index: c.uint, stride: ^c.uint) -> result ---
  compiler_type_struct_member_matrix_stride :: proc(compiler: compiler, type: type, index: c.uint, stride: ^c.uint) -> result ---

  /*
  * Workaround helper functions.
  * Maps to C++ API.
  */
  compiler_build_dummy_sampler_for_combined_images :: proc(compiler: compiler, id: ^variable_id) -> result ---
  compiler_build_combined_image_samplers :: proc(compiler: compiler) -> result ---
  compiler_get_combined_image_samplers :: proc(compiler: compiler, samplers: [^]combined_image_sampler, num_samplers: c.int) -> result ---

  /*
  * Constants
  * Maps to C++ API.
  */
  compiler_get_specialization_constants :: proc(compiler: compiler, constants: [^]specialization_constant, num_constants: c.int) -> result ---
  compiler_get_constant_handle :: proc(compiler: compiler, id: constant_id) -> constant ---

  compiler_get_work_group_size_specialization_constants :: proc(compiler: compiler, x: ^specialization_constant, y: ^specialization_constant, z: ^specialization_constant) -> constant ---

  /*
  * Buffer ranges
  * Maps to C++ API.
  */
  compiler_get_active_buffer_ranges :: proc(compiler: compiler, id: variable_id, ranges: [^]buffer_range, num_ranges: ^c.int) -> result ---

  /*
  * No stdint.h until C99, sigh :(
  * For smaller types, the result is sign or zero-extended as appropriate.
  * Maps to C++ API.
  * TODO: The SPIRConstant query interface and modification interface is not quite complete.
  */
  constant_get_scalar_fp16 :: proc(constant: constant, column: c.uint, row: c.uint) -> f32 ---
  constant_get_scalar_fp32 :: proc(constant: constant, column: c.uint, row: c.uint) -> f32 ---
  constant_get_scalar_fp64 :: proc(constant: constant, column: c.uint, row: c.uint) -> f64 ---
  constant_get_scalar_u32 :: proc(constant: constant,  column: c.uint, row: c.uint) -> c.uint ---
  constant_get_scalar_i32 :: proc(constant: constant,  column: c.uint, row: c.uint) -> i32 ---
  constant_get_scalar_u16 :: proc(constant: constant,  column: c.uint, row: c.uint) -> c.uint ---
  constant_get_scalar_i16 :: proc(constant: constant,  column: c.uint, row: c.uint) -> c.int ---
  constant_get_scalar_u8 :: proc(constant: constant, column: c.uint, row: c.uint) -> c.uint ---
  constant_get_scalar_i8 :: proc(constant: constant, column: c.uint, row: c.uint) -> c.int ---
  constant_get_subconstants :: proc(constant: constant, constituents: [^]constant_id, count: c.int) ---
  constant_get_type :: proc(constant: constant) -> type_id ---

  /*
  * C implementation of the C++ api.
  */
  constant_set_scalar_fp16 :: proc(constant: constant, column: c.uint, row: c.uint, value: i16) ---
  constant_set_scalar_fp32 :: proc(constant: constant, column: c.uint, row: c.uint, value: f32) ---
  constant_set_scalar_fp64 :: proc(constant: constant, column: c.uint, row: c.uint, value: f64) ---
  constant_set_scalar_u32 :: proc(constant: constant, column: c.uint, row: c.uint, value: u32) ---
  constant_set_scalar_i32 :: proc(constant: constant, column: c.uint, row: c.uint, value: i32) ---
  constant_set_scalar_u16 :: proc(constant: constant, column: c.uint, row: c.uint, value: i16) ---
  constant_set_scalar_i16 :: proc(constant: constant, column: c.uint, row: c.uint, value: i16) ---
  constant_set_scalar_u8 :: proc(constant: constant, column: c.uint, row: c.uint, value: u8) ---
  constant_set_scalar_i8 :: proc(constant: constant, column: c.uint, row: c.uint, value: i8) ---

  /*
  * Misc reflection
  * Maps to C++ API.
  */
  compiler_get_binary_offset_for_decoration :: proc(compiler: compiler, id: variable_id, decoration: SpvDecoration, word_offset: c.uint) -> bool ---
  compiler_buffer_is_hlsl_counter_buffer :: proc(compiler: compiler, id: variable_id) -> bool ---
  compiler_buffer_get_hlsl_counter_buffer :: proc(compiler: compiler, id: variable_id, counter_id: ^variable_id) -> bool ---

  compiler_get_declared_capabilities :: proc(compiler: compiler, capabilities: [^]SpvCapability, num_capabilities: c.int) -> result ---
  compiler_get_declared_extensions :: proc(compiler: compiler, extensions: [^]cstring, num_extensions: c.int) -> result ---

  compiler_get_remapped_declared_block_name :: proc(compiler: compiler, id: variable_id) -> cstring ---
  compiler_get_buffer_block_decorations :: proc(compiler: compiler, id: variable_id, decorations: [^]SpvDecoration, num_decorations: ^c.int) -> result ---
}

